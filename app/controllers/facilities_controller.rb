class FacilitiesController < ApplicationController
  include Swagger::Blocks
  swagger_path '/facilities' do
    operation :get do
      key :summary, 'Get facility list'
      key :description, 'facility Catalog'
      key :operationId, 'facilityIndex'
      key :produces, ['application/json',]
      key :tags, ['facility']
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
    json_response_data(Facilities.collection)
  end
end
