class ApplicationSessionsController < ::DeviseTokenAuth::SessionsController
  include Swagger::Blocks


  # custom rendering
  # Log in process
  swagger_path '/sign_in' do
    operation :post do
      key :summary, 'Email authentication'
      key :description, 'Requires email and password as params.
Authentication headers example:
"access-token": "wwwww",
"token-type":   "Bearer",
"client":       "xxxxx",
"expiry":       "yyyyy",
"uid":          "zzzzz"'
      key :operationId, 'signIn'
      key :produces, ['application/json',]
      key :tags, ['security']
      parameter do
        key :name, :email
        key :in, :body
        key :description, 'Email of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :password
        key :in, :body
        key :description, 'Password of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :user_type
        key :in, :body
        key :description, 'User type, admin, player and movil'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, 'This route will return a JSON representation of the User model on successful login along with the access-token and client in the header of the response.
in Header response :
access-token: wwwww
client:       xxxxx
expiry:       yyyyy
token-type: Bearer
uid:          zzzzz'
        schema do
          key :required, [:data]
          property :data do
            key :'$ref', :User
          end

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
    # Check
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

    @resource = nil
    if field
      q_value = get_case_insensitive_field_from_resource_params(field)

      @resource = find_resource(field, q_value)
    end
    if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      if @resource.status.to_s == "Inactive"
        return json_response_error(["Account inactive"], 401)
      end
      if resource_params[:password].present?
        valid_password = @resource.valid_password?(resource_params[:password])
      elsif resource_params[:birthdate].present?
        valid_password = @resource.valid_birthdate?(resource_params[:birthdate])
      elsif resource_params[:mobile].present?
        valid_password = @resource.valid_mobile?(resource_params[:mobile])
      else
        valid_password = true
      end
      if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
        return render_create_error_bad_credentials
      end
      @client_id, @token = @resource.create_token
      @resource.save

      sign_in(:user, @resource, store: false, bypass: false)

      yield @resource if block_given?

      render_create_success
    elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      if @resource.respond_to?(:locked_at) && @resource.locked_at
        render_create_error_account_locked
      else
        render_create_error_not_confirmed
      end
    else
      render_create_error_bad_credentials
    end
  end

  # Log out process
  swagger_path '/sign_out' do
    operation :delete do
      key :summary, 'Use this route to end the user\'s current session'
      key :description, 'This route will invalidate the user\'s authentication token. You must pass in uid, client, and access-token in the request headers.'
      key :operationId, 'signOut'
      key :produces, ['application/json',]
      key :tags, ['security']
      parameter do
        key :name, :uid
        key :in, :header
        key :description, 'Email of user, uuid in the request headers'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :client
        key :in, :header
        key :description, 'Client in the request headers'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'access-token'
        key :in, :header
        key :description, 'Access token in the request headers'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :required, [:success]
        key :description, 'User is singout'
        schema do
          property :success do
            key :type, :boolean
          end
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



  def render_create_success
    json_response_serializer(@resource, UserSerializer)
  end


  def resource_errors
    return @resource.errors
  end

  protected

  def valid_params?(key, val)
    key && val
  end

end