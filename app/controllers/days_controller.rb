class DaysController < ApplicationController
  include Swagger::Blocks
  swagger_path '/days' do
    operation :get do
      key :summary, 'Get days list'
      key :description, 'Days Catalog'
      key :operationId, 'daysIndex'
      key :produces, ['application/json',]
      key :tags, ['days']
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
    json_response_data(Days.collection)
  end
end
