class GeographyController < ApplicationController
  include Swagger::Blocks
  swagger_path '/geography' do
    operation :get do
      key :summary, 'Get geography list'
      key :description, 'Geography Catalog'
      key :operationId, 'geographyIndex'
      key :produces, ['application/json',]
      key :tags, ['geography']
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
    json_response_data(Geography.collection)
  end
end
