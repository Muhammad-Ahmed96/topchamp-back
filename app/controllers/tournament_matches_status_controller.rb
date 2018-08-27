class TournamentMatchesStatusController < ApplicationController
  include Swagger::Blocks
  swagger_path '/tournament_matches_status' do
    operation :get do
      key :summary, 'Get tournament matches status list'
      key :description, 'Days tournament matches status'
      key :operationId, 'tournamentMatchesStatusIndex'
      key :produces, ['application/json',]
      key :tags, ['tournament_matches_status']
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
    json_response_data(TournamentMatchesStatus.collection)
  end
end
