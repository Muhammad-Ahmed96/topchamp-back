class InvitationStatusController < ApplicationController
  include Swagger::Blocks
  swagger_path '/invitation_status' do
    operation :get do
      key :summary, 'Get invitation status list'
      key :description, 'Invitation status Catalog'
      key :operationId, 'invitationStatusIndex'
      key :produces, ['application/json',]
      key :tags, ['invitation_status']
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
    json_response_data(InvitationStatus.collection)
  end
end
