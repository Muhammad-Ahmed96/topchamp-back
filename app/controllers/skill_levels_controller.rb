class SkillLevelsController < ApplicationController
  include Swagger::Blocks
  swagger_path '/skill_levels' do
    operation :get do
      key :summary, 'Get skill levels list'
      key :description, 'Skill levels Catalog'
      key :operationId, 'skillLevelsIndex'
      key :produces, ['application/json',]
      key :tags, ['skill_levels']
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :type, :number
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
    json_response_data(SkillLevels.collection)
  end
end
