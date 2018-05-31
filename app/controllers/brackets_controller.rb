class BracketsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/brackets' do
    operation :get do
      key :summary, 'Get brackets list'
      key :description, 'Brackets Catalog'
      key :operationId, 'bracketsIndex'
      key :produces, ['application/json',]
      key :tags, ['brackets']
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
    json_response_data(Bracket.collection)
  end
end
