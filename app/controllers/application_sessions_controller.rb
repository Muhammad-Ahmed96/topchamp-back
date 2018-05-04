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

end