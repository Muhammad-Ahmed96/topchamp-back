class RestrictionsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/restrictions' do
    operation :get do
      key :summary, 'Get days list'
      key :description, 'Restrictions Catalog'
      key :operationId, 'restrictionsIndex'
      key :produces, ['application/json',]
      key :tags, ['restrictions']
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
    json_response_data(Restrictions.collection)
  end
end
