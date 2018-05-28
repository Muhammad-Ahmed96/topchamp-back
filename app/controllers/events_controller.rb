class EventsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:update, :create]
=begin
  swagger_path '/events' do
    operation :post do
      key :summary, 'List events'
      key :description, 'Event Catalog'
      key :operationId, 'eventsIndex'
      key :produces, ['application/json',]
      key :tags, ['events']
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
        key :description, ''
        schema do
          key :'$ref', :Event
          property :data do
            items do
              key :'$ref', :User
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
=end
  def index
    authorize Event

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate Event.my_order(column, direction), per_page: 50, root: :data
  end
  swagger_path '/events' do
    operation :post do
      key :summary, 'Save event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsCreate'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :venue_id
        key :in, :body
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :event_type_id
        key :in, :body
        key :required, true
        key :type, :int64
      end

      parameter do
        key :name, :title
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :icon
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :description
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :start_date
        key :in, :body
        key :required, false
        key :type, :date
      end
      parameter do
        key :name, :end_date
        key :in, :body
        key :required, false
        key :type, :date
      end
      parameter do
        key :name, :visibility
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :requires_access_code
        key :in, :body
        key :required, true
        key :type, :boolean
      end
      parameter do
        key :name, :event_url
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_event_sanctioned
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :sanctions
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :organization_name
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :organization_url
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_determine_later_venue
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
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
    event = Event.create!(resource_params)
    if !params[:sports].nil?
      event.sport_ids = params[:sports]
    end
    if !params[:regions].nil?
      event.region_ids = params[:regions]
    end
    json_response_success(t("created_success", model: Event.model_name.human), true)
  end
=begin
  swagger_path '/events/:id' do
    operation :post do
      key :summary, 'Show event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsShow'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :Event
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
=end

  def show
    authorize Event
    json_response_serializer(@event, EventSerializer)
  end
=begin
  swagger_path '/events/:id' do
    operation :put do
      key :summary, 'Edit event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsUpdate'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :venue_id
        key :in, :body
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :event_type_id
        key :in, :body
        key :required, true
        key :type, :int64
      end

      parameter do
        key :name, :title
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :icon
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :description
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :start_date
        key :in, :body
        key :required, false
        key :type, :date
      end
      parameter do
        key :name, :end_date
        key :in, :body
        key :required, false
        key :type, :date
      end
      parameter do
        key :name, :visibility
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :requires_access_code
        key :in, :body
        key :required, true
        key :type, :boolean
      end
      parameter do
        key :name, :event_url
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_event_sanctioned
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :sanctions
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :organization_name
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :organization_url
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_determine_later_venue
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
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
=end
  def update
    authorize Event
    if !params[:sports].nil?
      @event.sport_ids = params[:sports]
    end
    if !params[:regions].nil?
      @event.region_ids = params[:regions]
    end
    @event.update!(resource_params)
    json_response_success(t("edited_success", model: Event.model_name.human), true)
  end
=begin
  swagger_path '/events/:id' do
    operation :delete do
      key :summary, 'Delete event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsDelete'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
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
=end
  def destroy
    authorize Event
    @event.destroy
    json_response_success(t("deleted_success", model: Event.model_name.human), true)
  end

  def icon
    authorize Event
    @event.update!(resource_icon_params)
    json_response_success(t("edited_success", model: Event.model_name.human), true)
  end
  swagger_path '/events_validate_url' do
    operation :get do
      key :summary, 'Validate the URL'
      key :description, 'Event Catalog'
      key :operationId, 'eventsValidateUrl'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :url
        key :in, :query
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
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
  def validate_url
    if params[:url].present?
      event = Event.find_by_event_url(params[:url])
      if event.nil?
        json_response_success(t("available_url"), true)
      else
        json_response_error([t("taken_url")], 422)
      end
    else
      json_response_error([t("no_url")], 422)
    end
  end
  private
  def resource_params
    # whitelist params
    params.permit(:venue_id, :event_type_id, :title, :icon, :description, :start_date, :end_date, :visibility,
                  :requires_access_code, :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
                  :is_determine_later_venue)
  end

  def resource_icon_params
    # whitelist params
    params.permit(:icon)
  end
  def set_resource
    @event = Event.find(params[:id])
  end
end
