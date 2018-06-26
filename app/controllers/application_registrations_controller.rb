class ApplicationRegistrationsController < ::DeviseTokenAuth::RegistrationsController
  include Swagger::Blocks
  around_action :transactions_filter, only: [:update, :create]
  swagger_path '/' do
    operation :post do
      key :summary, 'Sing Up users'
      key :description, 'Users register'
      key :operationId, 'singUpCreate'
      key :produces, ['application/json',]
      key :tags, ['singUp']
      parameter do
        key :name, :first_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :last_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :email
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password_confirmation
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :contact_information
        key :in, :body
        key :description, 'Contact information'
        schema do
          key :'$ref', :ContactInformationInputSingUp
        end
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
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def create
    build_resource

    unless @resource.present?
      raise DeviseTokenAuth::Errors::NoResourceDefinedError,
            "#{self.class.name} #build_resource does not define @resource, execution stopped"
    end

    # give redirect value from params priority
    @redirect_url = params.fetch(
        :confirm_success_url,
        DeviseTokenAuth.default_confirm_success_url
    )

    # success redirect url is required
=begin
    if confirmable_enabled? && !@redirect_url
      return render_create_error_missing_confirm_success_url
    end
=end

    # if whitelist is set, validate redirect_url against whitelist
    #return render_create_error_redirect_url_not_allowed if blacklisted_redirect_url?

    begin
      # override email confirmation, must be sent manually from ctrl
      resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)

      if @resource.respond_to? :skip_confirmation_notification!
        # Fix duplicate e-mails by disabling Devise confirmation e-mail
        @resource.skip_confirmation_notification!
      end
      @resource.status = :Inactive
      @resource.role = :Director
      if @resource.save
        if !params[:contact_information].nil?
          @resource.create_contact_information! contact_information_params
        end
        yield @resource if block_given?

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
                                                       client_config: params[:config_name],
                                                       redirect_url: @redirect_url
                                                   })
        else
          # email auth has been bypassed, authenticate user
          @client_id, @token = @resource.create_token
          @resource.save!
          update_auth_header
        end
        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render_create_error_email_already_exists
    end
  end

  def sign_up_params
    params.permit(*params_for_resource(:sign_up))
  end

  def resource_errors
    return @resource.errors
  end

  protected

  def build_resource
    @resource            = resource_class.new(sign_up_params)
    @resource.provider   = provider

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @resource.email = sign_up_params[:email].try(:downcase)
    else
      @resource.email = sign_up_params[:email]
    end
  end

  def render_create_error_missing_confirm_success_url
    response = {
        status: 'error',
        data:   resource_data
    }
    message = I18n.t('devise_token_auth.registrations.missing_confirm_success_url')
    render_error(422, message, response)
  end

  def render_create_error_redirect_url_not_allowed
    response = {
        status: 'error',
        data:   resource_data
    }
    message = I18n.t('devise_token_auth.registrations.redirect_url_not_allowed', redirect_url: @redirect_url)
    render_error(422, message, response)
  end

  def render_create_success
    json_response_success(t("devise.confirmations.send_instructions"), true)
  end

  def render_create_error
    render json: {
        status: 'error',
        #data:   resource_data,
        errors: resource_errors
    }, status: 422
  end

  def render_create_error_email_already_exists
    response = {
        status: 'error',
        data:   resource_data
    }
    message = I18n.t('devise_token_auth.registrations.email_already_exists', email: @resource.email)
    render_error(422, message, response)
  end

  def render_update_success
    render json: {
        status: 'success',
        data:   resource_data
    }
  end

  def render_update_error
    render json: {
        status: 'error',
        errors: resource_errors
    }, status: 422
  end

  def render_update_error_user_not_found
    render_error(404, I18n.t('devise_token_auth.registrations.user_not_found'), { status: 'error' })
  end

  def render_destroy_success
    render json: {
        status: 'success',
        message: I18n.t('devise_token_auth.registrations.account_with_uid_destroyed', uid: @resource.uid)
    }
  end

  def render_destroy_error
    render_error(404, I18n.t('devise_token_auth.registrations.account_to_destroy_not_found'), { status: 'error' })
  end

  def contact_information_params
    # whitelist params
    params.require(:contact_information).permit(:cell_phone, :country_code_phone, :alternative_email, :address_line_1, :address_line_2,
                                                :postal_code, :state, :city,:country_code_work_phone , :work_phone, :emergency_contact_full_name,
                                                :emergency_contact_country_code_phone, :emergency_contact_phone, :is_receive_text)
  end

  private

  def resource_update_method
    if DeviseTokenAuth.check_current_password_before_update == :attributes
      'update_with_password'
    elsif DeviseTokenAuth.check_current_password_before_update == :password && account_update_params.has_key?(:password)
      'update_with_password'
    elsif account_update_params.has_key?(:current_password)
      'update_with_password'
    else
      'update_attributes'
    end
  end

  def validate_sign_up_params
    validate_post_data sign_up_params, I18n.t('errors.messages.validate_sign_up_params')
  end

  def validate_account_update_params
    validate_post_data account_update_params, I18n.t('errors.messages.validate_account_update_params')
  end

  def validate_post_data which, message
    render_error(:unprocessable_entity, message, { status: 'error' }) if which.empty?
  end
end
