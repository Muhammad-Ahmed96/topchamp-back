class EventSchedulersController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:create, :index, :show]
  around_action :transactions_filter, only: [:create]

  swagger_path '/events/:event_id/schedules' do
    operation :get do
      key :summary, 'Events schedules list'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesList'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :description, 'Event Schedule response'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :EventSchedule
            end
            key :description, "Information container"
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
    json_response_serializer_collection( @event.schedules, EventScheduleSerializer)
  end

  swagger_path '/events/:event_id/schedules' do
    operation :post do
      key :summary, 'Events schedules'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesCreate'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :schedules
        key :in, :body
        key :description, 'Schedules array'
        key :required, true
        key :required, true
        schema do
          key :type, :array
          items do
            key :'$ref', :EventScheduleInput
          end
        end
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :Event
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
  def create
    authorize Event
    @event.sync_schedules! schedules_params
    json_response_serializer(@event, EventSerializer)
  end


  swagger_path '/events/:event_id/schedules/:id' do
    operation :get do
      key :summary, 'Events schedules show'
      key :description, 'Events Catalog'
      key :operationId, 'eventsSchedulesShow'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :description, 'Event Schedule response'
        schema do
          key :type, :object
          key :'$ref', :EventSchedule
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
  def show
    json_response_serializer( @event.schedules.where(:id => params[:id]).first!, EventScheduleSerializer)
  end

  private
  def schedules_params
    #validate presence and type
    unless params[:schedules].nil? and !params[:schedules].kind_of?(Array)
      params[:schedules].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :agenda_type_id, :venue, :title, :instructor, :description, :start_date, :end_date, :start_time,
                                                               :end_time, :cost, :capacity, :category_id)
      end
    end
  end
  # search current resource of id
  def set_resource
    #apply policy scope
    @event = Event.find(params[:event_id])
  end
end
