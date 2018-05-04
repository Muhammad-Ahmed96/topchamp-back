class ApplicationSessionsController < ::DeviseTokenAuth::SessionsController
  include Swagger::Blocks

  protected

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
      key :tags, ['sign_in']
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
      response 200 do
        key :name, 'User'
        key :description, 'This route will return a JSON representation of the User model on successful login along with the access-token and client in the header of the response.
in Header response :
access-token: wwwww
client:       xxxxx
expiry:       yyyyy
token-type: Bearer
uid:          zzzzz'
        schema do
          key :required, [:id, :email, :provider, :uid, :allow_password_change, :name, :nickname, :image]
          property :id do
            key :type, :integer
            key :format, :int64
          end
          property :email do
            key :type, :string
          end
          property :provider do
            key :type, :string
          end
          property :uid do
            key :type, :string
          end
          property :allow_password_change do
            key :type, :boolean
          end
          property :name do
            key :type, :string
          end
          property :nickname do
            key :type, :string
          end
          property :image do
            key :type, :string
          end
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  # Log out process
  swagger_path '/sign_out' do
    operation :delete do
      key :summary, 'Use this route to end the user\'s current session'
      key :description, 'This route will invalidate the user\'s authentication token. You must pass in uid, client, and access-token in the request headers.'
      key :operationId, 'signOut'
      key :produces, ['application/json',]
      key :tags, ['sign_out']
      parameter do
        key :name, :uid
        key :in, :body
        key :description, 'Email of user, uuid in the request headers'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :client
        key :in, :body
        key :description, 'Client in the request headers'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'access-token'
        key :in, :body
        key :description, 'Access token in the request headers'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, '.'
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

end