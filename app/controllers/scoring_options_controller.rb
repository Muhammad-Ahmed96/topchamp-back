class ScoringOptionsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/scoring_options' do
    operation :get do
      key :summary, 'Get scoring options list'
      key :description, 'Scoring options Catalog'
      key :operationId, 'scoringOptionsIndex'
      key :produces, ['application/json',]
      key :tags, ['scoring_options']
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :'$ref', :ScoringOption
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
    json_response_serializer_collection(ScoringOption.all, ScoringOptionSerializer)
  end
end
