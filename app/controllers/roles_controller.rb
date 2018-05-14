class RolesController < ApplicationController
  include Swagger::Blocks
  swagger_path '/roles' do
    operation :get do
      key :summary, 'Get rolese list'
      key :description, 'Roles Catalog'
      key :operationId, 'rolesIndex'
      key :produces, ['application/json',]
      key :tags, ['roles']
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :type, :string
            end
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
  def index
    json_response_data(Roles.collection)
  end
end
