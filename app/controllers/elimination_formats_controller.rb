class EliminationFormatsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/elimination_formats' do
    operation :get do
      key :summary, 'Get elimination formats list'
      key :description, 'Elimination formats Catalog'
      key :operationId, 'eliminationFormatsIndex'
      key :produces, ['application/json',]
      key :tags, ['elimination_formats']
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
    json_response_data(EliminationFormat.collection)
  end
end
