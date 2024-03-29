class ApplicationPasswordController < ::DeviseTokenAuth::PasswordsController
  include Swagger::Blocks
  include DeviseTokenAuth::Concerns::SetUserByToken

  # this action is responsible for generating password reset tokens and
  # sending emails
  swagger_path '/password' do
    operation :post do
      key :summary, 'Send email password reset'
      key :description, 'Use this route to send a password reset confirmation email to users that registered by email'
      key :operationId, 'resetPassword'
      key :produces, ['application/json',]
      key :tags, ['security']
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'The user matching the email param will be sent instructions on how to reset their password'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :redirect_url
        key :in, :body
        key :description, 'is the url to which the user will be redirected after visiting the link contained in the email'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'Mail send successful'
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response 404 do
        key :description, 'not found'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def create
    unless resource_params[:email]
      return render_create_error_missing_email
    end

    # give redirect value from params priority
    @redirect_url = params.fetch(
        :redirect_url,
        DeviseTokenAuth.default_password_reset_url
    )

    return render_create_error_missing_redirect_url unless @redirect_url
    # return render_create_error_not_allowed_redirect_url if blacklisted_redirect_url?

    @email = get_case_insensitive_field_from_resource_params(:email)
    @resource = find_resource(:uid, @email)

    if @resource.nil?
      return render_not_found_error
    end
    unless @resource.active_for_authentication?
      return render_create_error_not_confirmed
    end
    
    if @resource
      yield @resource if block_given?
      @resource.send_reset_password_instructions({
                                                     email: @email,
                                                     provider: 'email',
                                                     redirect_url: @redirect_url,
                                                     client_config: params[:config_name]
                                                 })

      if @resource.errors.empty?
        return render_create_success
      else
        render_create_error @resource.errors
      end
    else
      render_not_found_error
    end
  end

  # this is where users arrive after visiting the password reset confirmation link
  def edit
    # if a user is not found, return nil
    @resource = resource_class.with_reset_password_token(resource_params[:reset_password_token])
    if @resource && @resource.reset_password_period_valid?
      token = @resource.create_token unless require_client_password_reset_token?
      client_id = token

      # ensure that user is confirmed
      @resource.skip_confirmation! if confirmable_enabled? && !@resource.confirmed_at
      # allow user to change password once without current_password
      @resource.allow_password_change = true if recoverable_enabled?

      @resource.save!

      yield @resource if block_given?

      if require_client_password_reset_token?
        redirect_to DeviseTokenAuth::Url.generate(@redirect_url, reset_password_token: resource_params[:reset_password_token])
      else
        redirect_header_options = { reset_password: true }
        redirect_headers = build_redirect_headers(token.token,
                                                  token.client,
                                                  redirect_header_options)
        redirect_to(@resource.build_auth_url(@redirect_url,
                                             redirect_headers))
      end
    else
      render_edit_error
    end
  end

  # Update password
  swagger_path '/password' do
    operation :put do
      key :summary, 'Update password of reset'
      key :description, 'Use this route to change users\' passwords'
      key :operationId, 'updatePassword'
      key :produces, ['application/json',]
      key :tags, ['security']
      parameter do
        key :name, "password"
        key :in, :body
        key :description, 'Password'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'current_password'
        key :in, :body
        key :description, 'current password'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, 'password_confirmation'
        key :in, :body
        key :description, 'Password confirmation'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'access-token'
        key :in, :body
        key :description, 'This serves as the user\'s password for each request.'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'token-type'
        key :in, :body
        key :description, 'Type of authentication'
        key :required, true
        key :type, :string
        key :default, 'Bearer'
      end
      parameter do
        key :name, 'client'
        key :in, :body
        key :description, 'This enables the use of multiple simultaneous sessions on different clients.'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'expiry'
        key :in, :body
        key :description, 'The date at which the current session will expire'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'uid'
        key :in, :body
        key :description, 'A unique value that is used to identify the user'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response 404 do
        key :description, 'not found'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def update
    # make sure user is authorized
    if require_client_password_reset_token? && resource_params[:reset_password_token]
      @resource = resource_class.with_reset_password_token(resource_params[:reset_password_token])
      return render_update_error_unauthorized unless @resource

      @token = @resource.create_token
    else
      @resource = set_user_by_token
    end

    return render_update_error_unauthorized unless @resource

    # make sure account doesn't use oauth2 provider
    unless @resource.provider == 'email'
      return render_update_error_password_not_required
    end

    # ensure that password params were sent
    unless password_resource_params[:password] && password_resource_params[:password_confirmation]
      return render_update_error_missing_password
    end

    if @resource.send(resource_update_method, password_resource_params)
      @resource.allow_password_change = false if recoverable_enabled?
      @resource.save!

      yield @resource if block_given?
      return render_update_success
    else
      return render_update_error
    end
  end

  def update_password
    @resource = User.find_by_reset_password_token(params[:reset_password_token])
    @token = @resource.create_token
    @cient_id = @token
    @resource.save

    if @resource.update(password: params[:password])
      sign_in(:user, @resource, store: false, bypass: false)
      yield @resource if block_given?
      return render_update_success
    else
      return render_update_error
    end
  end



  def render_edit_error
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_create_error_not_confirmed
    render_error(401, I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email))
  end

  def resource_errors
    return @resource.errors
  end
end