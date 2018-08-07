class EventSchedulersController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:create]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]

  swagger_path '/events/:id/schedules' do
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

  private
  def schedules_params
    #validate presence and type
    unless params[:schedules].nil? and !params[:schedules].kind_of?(Array)
      params[:schedules].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :agenda_type_id, :venue_id, :title, :instructor, :description, :start_date, :end_date, :start_time,
                                                               :end_time, :cost, :capacity)
      end
    end
  end
  # search current resource of id
  def set_resource
    #apply policy scope
    @event = EventPolicy::Scope.new(current_user, Event).resolve.find(params[:event_id])
  end
end
