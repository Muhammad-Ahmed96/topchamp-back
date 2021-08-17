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
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :direction
        key :in, :query
        key :description, 'Direction to order'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Event Type Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :EventType
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', :PaginateModel
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
    paginate EventType.my_order(column, direction).search(search), per_page: 50, root: :data
  end

  def create
    authorize EventType
    resource = EventType.create!(resource_params)
    json_response_success(t("created_success", model: EventType.model_name.human), true)
  end


  private

  def resource_params
    params.permit(:name)
  end

end
