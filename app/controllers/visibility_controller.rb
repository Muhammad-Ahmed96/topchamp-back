class VisibilityController < ApplicationController
  include Swagger::Blocks
  swagger_path '/visibility' do
    operation :get do
      key :summary, 'Get visibility list'
      key :description, 'Visibility Catalog'
      key :operationId, 'visibilityIndex'
      key :produces, ['application/json',]
      key :tags, ['visibility']
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
    json_response_data(Visibility.collection)
  end
end
