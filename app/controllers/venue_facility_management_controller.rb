class VenueFacilityManagementController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/venue_facility_management' do
    operation :get do
      key :summary, 'Get venue facility management list'
      key :description, 'Venue facility management Catalog'
      key :operationId, 'venueFacilityManagementIndex'
      key :produces, ['application/json',]
      key :tags, ['venue facility management']
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :'$ref', :VenueFacilityManagement
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
    authorize Venue
    json_response_data(VenueFacilityManagement.all)
  end
end
