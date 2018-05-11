class EventTypesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/event_types' do
    operation :get do
      key :summary, 'Get event type list'
      key :description, 'Event type Catalog'
      key :operationId, 'eventTypeIndex'
      key :produces, ['application/json',]
      key :tags, ['event types']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :EventType
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
    authorize EventType
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'name': params[:column]
    direction = params[:direction].nil? ? 'asc': params[:direction]
    paginate EventType.unscoped.my_order(column, direction).search(search), per_page: 50, root: :data
  end

end
