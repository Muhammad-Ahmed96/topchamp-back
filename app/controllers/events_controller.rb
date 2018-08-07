class EventsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:update, :destroy, :activate, :inactive, :create_venue, :payment_information,
                                      :payment_method, :discounts, :import_discount_personalizeds, :tax, :refund_policy,
                                      :service_fee, :venue, :details, :agendas, :categories]
  around_action :transactions_filter, only: [:update, :create, :create_venue, :discounts, :import_discount_personalizeds,
                                             :details, :activate, :agendas]


  swagger_path '/events' do
    operation :get do
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
        key :description, 'Direction to order special "sport_name" parameter for sports order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :title
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :start_date
        key :in, :query
        key :description, 'Start date'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :status
        key :in, :query
        key :description, 'Status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Id of te sport filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :visibility
        key :in, :query
        key :description, 'Visibility filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Event Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Event
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
    authorize Event

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    title = params[:title]
    start_date = params[:start_date]
    status = params[:status]
    visibility = params[:visibility]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    events = EventPolicy::Scope.new(current_user, Event).resolve.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .start_date_like(start_date).in_status(status).state_like(state).city_like(city).in_visibility(visibility)

    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
  end

  swagger_path '/events/coming_soon' do
    operation :get do
      key :summary, 'Coming soon events'
      key :description, 'Event Catalog'
      key :operationId, 'eventsComingSoon'
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
        key :description, 'Direction to order special "sport_name" parameter for sports order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :title
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :start_date
        key :in, :query
        key :description, 'Start date'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :status
        key :in, :query
        key :description, 'Status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Id of te sport filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Event Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', Event
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
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

  def coming_soon
    authorize Event

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    title = params[:title]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    events = Event.coming_soon.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .in_status("Active").state_like(state).city_like(city).in_visibility("Public")
    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
  end

  swagger_path '/events/upcoming' do
    operation :get do
      key :summary, 'Upcoming events'
      key :description, 'Event Catalog'
      key :operationId, 'eventsUpcoming'
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
        key :description, 'Direction to order special "sport_name" parameter for sports order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :title
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :start_date
        key :in, :query
        key :description, 'Start date'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :status
        key :in, :query
        key :description, 'Status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Id of te sport filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :only_director
        key :in, :query
        key :description, 'show only events of current director {any} = no, 1 = yes'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Event Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Event
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

  def upcoming
    authorize Event

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    only_director = params[:only_director].nil? ? '0' : params[:only_director]

    title = params[:title]


    state = params[:state]
    city = params[:city]

    sport_id = params[:sport_id]
    column_sports = nil
    if column.to_s == "sport_name"
      column_sports = "name"
      column = nil
    end


    column_venue = nil
    if column.to_s == "state" || column.to_s == "city"
      column_venue = column
      column = nil
    end
    director_id = nil
    if only_director.to_s == "1" and  !(@resource.sysadmin? || @resource.agent?)
      director_id = @resource.id
    end
    events = Event.upcoming.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .in_status("Active").state_like(state).city_like(city).in_visibility("Public").only_directors(director_id)
    if paginate.to_s == "0"
      json_response_serializer_collection(events.all, EventSerializer)
    else
      paginate events, per_page: 50, root: :data
    end
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
        key :name, :access_code
        key :in, :body
        key :required, false
        key :type, :string
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
        key :name, :sports
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :regions
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
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
    unless resource_params[:status].nil?
      params[:status] = :Inactive
    end
    @event = Event.create!(resource_params)
    if !params[:sports].nil?
      @event.sport_ids = params[:sports]
    end
    if !params[:regions].nil?
      @event.region_ids = params[:regions]
    end
    participant = Participant.where(:user_id => @resource.id).where(:event_id => @event.id).first_or_create!
    participant.attendee_type_ids = [AttendeeType.director_id]
    #@event.public_url
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id' do
    operation :get do
      key :summary, 'Show event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsShow'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'ID of event to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Event Respone'
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

  def show
    authorize Event
    @event = Event.find(params[:id])
    json_response_serializer(@event, EventSerializer)
  end

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
        key :name, :access_code
        key :in, :body
        key :required, false
        key :type, :string
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
        key :name, :sports
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :regions
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
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

  def update
    authorize Event
    if !sports_params[:sports].nil?
      @event.sport_ids = sports_params[:sports]
    end
    if !params[:regions].nil?
      @event.region_ids = params[:regions]
    end
    if (resource_params[:visibility].present? && @event.visibility == "Public" && @event.status == "Active")
      params.delete(:visibility)
    end
    @event.update!(resource_params)
    #@event.remove_public_url
    json_response_serializer(@event, EventSerializer)
  end


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

  def destroy
    authorize Event
    @event.destroy
    json_response_success(t("deleted_success", model: Event.model_name.human), true)
  end

  def icon
    authorize Event
    @event.update!(resource_icon_params)
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/create_venue' do
    operation :put do
      key :summary, 'Add venue to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsCreateVenue'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :abbreviation
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :country_code
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :phone_number
        key :in, :body
        key :required, false
        key :type, :date
      end
      parameter do
        key :name, :link
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :sports
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :address_line_1
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :address_line_2
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :postal_code
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :country
        key :in, :body
        key :required, false
        key :type, :string
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

  def create_venue
    authorize Event
    venue = Venue.create!(venue_params)
    @event.venue_id = venue.id
    @event.save!(:validate => false)
    if !params[:sports].nil?
      venue.sport_ids = params[:sports]
    end
    if !params[:facility_management].nil?
      venue.create_facility_management! facility_management_params
    end
    if params[:pictures].present?
      params[:pictures].each {|image|
        venue.pictures.create!(picture: image)
      }
    end
    if day_params[:days].present?
      venue.days.create!(day_params[:days])
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/venue' do
    operation :put do
      key :summary, 'Set venue to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventsVenue'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :venue_id
        key :in, :body
        key :required, true
        key :type, :int64
      end
      parameter do
        key :name, :is_determine_later_venue
        key :in, :body
        key :required, true
        key :type, :boolean
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

  def venue
    authorize Event
    if params[:is_determine_later_venue].present? and (params[:is_determine_later_venue].equal?(true) or params[:is_determine_later_venue].to_s == "1")
      @event.is_determine_later_venue = true
      @event.venue_id = nil
      @event.save!(:validate => false)
      json_response_serializer(@event, EventSerializer)
    else
      if params[:venue_id].present?
        @event.venue_id = params[:venue_id]
        @event.save!(:validate => false)
        json_response_serializer(@event, EventSerializer)
      else
        json_response_error([t("no_venue_present")], 422)
      end
    end

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

  swagger_path '/events/:id/activate' do
    operation :put do
      key :summary, 'Activate event'
      key :description, 'Events Catalog'
      key :operationId, 'eventsActivate'
      key :produces, ['application/json',]
      key :tags, ['events']
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

  def activate
    authorize Event
    if @event.valid_to_activate?
      @event.status = :Active
      @event.save!(:validate => false)
      @event.public_url
      json_response_serializer(@event, EventSerializer)
    else
      json_response_error([t("unable_activate")], 422)
    end
  end

  swagger_path '/events/:id/inactive' do
    operation :put do
      key :summary, 'Inactive events'
      key :description, 'Events Catalog'
      key :operationId, 'eventsInactive'
      key :produces, ['application/json',]
      key :tags, ['events']
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

  def inactive
    authorize Event
    @event.status = :Inactive
    @event.save!(:validate => false)
    #@event.remove_public_url
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/payment_information' do
    operation :put do
      key :summary, 'Payment information events'
      key :description, 'Events Catalog'
      key :operationId, 'eventsPaymentInformation'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :payment_information
        key :in, :body
        key :description, 'Payment information'
        schema do
          key :'$ref', :EventPaymentInformationInput
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

  def payment_information
    authorize Event
    information = @event.payment_information
    if information.present?
      information.update!(payment_information_params)
    else
      @event.create_payment_information!(payment_information_params)
    end
    json_response_serializer(@event, EventSerializer)
  end


  swagger_path '/events/:id/payment_method' do
    operation :put do
      key :summary, 'Payment method events'
      key :description, 'Events Catalog'
      key :operationId, 'eventsPaymentMethod'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :payment_method
        key :in, :body
        key :description, 'Payment method'
        schema do
          key :'$ref', :EventPaymentMethodInput
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

  def payment_method
    authorize Event
    if payment_method_params.present?
      payment_method = @event.payment_method
      if payment_method.present?
        payment_method.update!(payment_method_params)
      else
        @event.create_payment_method!(payment_method_params)
      end
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/discounts' do
    operation :put do
      key :summary, 'Events discounts '
      key :description, 'Events Catalog'
      key :operationId, 'eventsDiscounts'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :discounts
        key :in, :body
        key :description, 'Discounts'
        schema do
          key :'$ref', :EventDiscountInput
        end
      end
      parameter do
        key :name, :discount_generals
        key :in, :body
        key :description, 'Discount generals'
        key :type, :array
        items do
          key :'$ref', :EventDiscountGeneralInput
        end
      end
      parameter do
        key :name, :discount_personalizeds
        key :in, :body
        key :description, 'Discount personalizeds'
        key :type, :array
        items do
          key :'$ref', :EventDiscountPersonalizedInput
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

  def discounts
    authorize Event
    # Save discounts of te event
    if discounts_params.present?
      EventDiscount.where(:event_id => @event.id).update_or_create!(discounts_params)
    end
    # Syncronize array discounts
    @event.sync_discount_generals! discount_generals_params
    @event.sync_discount_personalizeds! discount_personalizeds_params
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/import_discount_personalizeds' do
    operation :put do
      key :summary, 'Events import discount personalizeds '
      key :description, 'Events Catalog'
      key :operationId, 'eventsImportDiscountPersonalizeds'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :file
        key :in, :body
        key :description, 'CSV with information {Email|Code|Discount}'
        key :type, :file
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

  def import_discount_personalizeds
    authorize Event
    @event.import_discount_personalizeds!(import_params[:file])
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/tax' do
    operation :put do
      key :summary, 'Events Tax'
      key :description, 'Events Catalog'
      key :operationId, 'eventsTax'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :tax
        key :in, :body
        key :description, 'Taxes'
        schema do
          key :'$ref', :EventTaxInput
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

  def tax
    authorize Event
    if tax_params.present?
      tax = @event.tax
      if tax.present?
        tax.update! tax_params
      else
        @event.create_tax! tax_params
      end
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/refund_policy' do
    operation :put do
      key :summary, 'Events refund policy'
      key :description, 'Events Catalog'
      key :operationId, 'eventsRefundPolicy'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :payment_information
        key :in, :body
        key :description, 'Taxes'
        schema do
          key :'$ref', :EventPaymentInformationRefundPolicy
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

  def refund_policy
    authorize Event
    if refund_policy_params.present?
      information = @event.payment_information
      if information.present?
        information.update!(refund_policy_params)
      else
        @event.create_payment_information!(refund_policy_params)
      end
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/service_fee' do
    operation :put do
      key :summary, 'Events service fee'
      key :description, 'Events Catalog'
      key :operationId, 'eventsServiceFee'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :payment_information
        key :in, :body
        key :description, 'Taxes'
        schema do
          key :'$ref', :EventPaymentInformationServiceFee
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

  def service_fee
    authorize Event
    if service_fee_params.present?
      information = @event.payment_information
      if information.present?
        information.update!(service_fee_params)
      else
        @event.create_payment_information!(service_fee_params)
      end
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/details' do
    operation :put do
      key :summary, 'Events details'
      key :description, 'Events Catalog'
      key :operationId, 'eventsDetails'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :sport_regulator_id
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :categories
        key :in, :body
        key :required, false
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
        end
      end
      parameter do
        key :name, :elimination_format_id
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :bracket_by
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :scoring_option_match_1_id
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :scoring_option_match_2_id
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :brackets
        key :in, :body
        key :description, 'Brackets'
        key :type, :array
        items do
          key :'$ref', :EventBracketInput
        end
      end
      parameter do
        key :name, :awards_for
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :awards_through
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :awards_plus
        key :in, :body
        key :required, false
        key :type, :string
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

  def details
    authorize Event
    unless categories_params[:categories].nil?
      @event.internal_category_ids = categories_params[:categories]
    end
    @event.update! details_params
    @event.sync_brackes! bracket_params
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/agendas' do
    operation :put do
      key :summary, 'Events agendas '
      key :description, 'Events Catalog'
      key :operationId, 'eventsAgendas'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :agendas
        key :in, :body
        key :description, 'Agendas'
        key :type, :array
        items do
          key :'$ref', :EventAgendaInput
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

  def agendas
    authorize Event
      @event.sync_agendas! agenda_params
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/categories' do
    operation :get do
      key :summary, 'Events categories List '
      key :description, 'Events Catalog'
      key :operationId, 'eventsCategoriesList'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :name, :categories
        key :description, 'categories'
        schema do
          key :type, :array
          items do
            key :'$ref', :Category
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

  def categories
    authorize Event
    json_response_serializer_collection(@event.categories, EventCategorySerializer)
  end

  swagger_path '/events/:id/available_categories' do
    operation :get do
      key :summary, 'Events categories List '
      key :description, 'Categories filter for the current user'
      key :operationId, 'eventsAvailableCategories'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        key :name, :categories
        key :description, 'categories'
        schema do
          key :type, :array
          items do
            key :'$ref', :CategoryBrackets
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

  def available_categories
    @event =  Event.find(params[:id])
    response_data = []
    gender = @resource.gender
    event_categories = @event.categories
    if @event.only_for_men and gender == "Female"
      return response_message_error(t("only_for_men_event"), 0)
    elsif @event.only_for_women and gender == "Male"
      return response_message_error(t("only_for_women_event"), 1)
    end
    # validate gender categories
    if gender == "Male"
      event_categories = event_categories.only_men
    elsif gender == "Female"
      event_categories = event_categories.only_women
    end
    #validate bracket
    player = Player.where(user_id: @resource.id).where(event_id: @event.id).first_or_create!

    age = player.present? ? player.user.age : nil
    #skill = player.present? ? player.skill_level.present? ? player.skill_level: -1000 : nil
    skill = player.present? ? player.skill_level: nil
    event_categories.each do |item|
      item.player = player
    end
    event_categories.to_a.each do |item|
      if @event.bracket_by == "age" or @event.bracket_by == "skill"
        if item.brackets.length > 0
          response_data << item
        end
      elsif @event.bracket_by == "skill_age" or @event.bracket_by == "age_skill"
        if item.brackets.length > 0
          not_in = player.brackets.where(:category_id => item[:id]).pluck(:event_bracket_id)
          item.brackets.each do |bra|
            if bra.brackets.age_filter(age, @event.sport_regulator.allow_age_range).skill_filter(skill).not_in(not_in).length > 0
              response_data << item
            end
          end

        end
      end
    end
    if response_data.length == 0
      if @event.bracket_by == "age"
        return response_message_error(t("not_age_bracket"), 3)
      elsif@event.bracket_by == "skill"
        return response_message_error(t("not_skill_braket"), 4)
      elsif@event.bracket_by == "skill_age"
        return response_message_error(t("not_skill_braket"), 5)
      elsif@event.bracket_by == "age_skill"
        return response_message_error(t("not_age_bracket"), 6)
      end
    end
    json_response_serializer_collection(response_data, EventCategorySerializer)
  end


  swagger_path '/events/downloads/discounts_template.xlsx' do
    operation :get do
      key :summary, 'Discounts download template'
      key :description, 'Invitations'
      key :operationId, 'eventsDownloadDiscountsTemplate'
      key :produces, ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',]
      key :tags, ['events']
      response 200 do
        key :description, 'template'
        key :type, :string
        key :format, :binary
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

  def download_discounts_template
    send_file("#{Rails.root}/app/assets/template/discounts-template.xlsx",
              filename: "discounts-template.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  swagger_path '/events/:id/registration_fee' do
    operation :get do
      key :summary, 'Events registratiosn fee '
      key :description, 'Get current registration fee'
      key :operationId, 'eventsGetRegistrationFee'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :discount_code
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :brackets_count
        key :in, :body
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :name, :categories
        key :description, 'categories'
        schema do
          key :type, :array
          items do
            key :'$ref', :CategoryBrackets
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
  def get_registration_fee
    @event = Event.find(params[:id])
    #set tax of event
    tax = @event.tax
    brackets_count = subscribe_params[:brackets_count].present? ? subscribe_params[:brackets_count].to_i : 1
    payment_method = @event.payment_method
    enroll_fee = @event.registration_fee
    bracket_fee = payment_method.present? ? payment_method.bracket_fee : 0
    bracket_fee = bracket_fee *  brackets_count
    tax_amount = 0

    if tax.present?
      if tax.is_percent
        tax_amount = (tax.tax * amount) / 100
      else
        tax_amount = tax.tax
      end

    end

    #apply discounts
    #event_discount = @event.get_discount
    personalized_discount = @event.discount_personalizeds.where(:code => subscribe_params[:discount_code]).where(:email => @resource.email).first
    general_discount = subscribe_params[:discount_code].present? ?  @event.discount_generals.where(:code => subscribe_params[:discount_code]).first : nil

    #enroll_fee = enroll_fee - ((event_discount * enroll_fee) / 100)
    #bracket_fee = bracket_fee - ((event_discount * bracket_fee) / 100)

    if personalized_discount.present?
      enroll_fee =  enroll_fee - ((personalized_discount.discount * enroll_fee) / 100)
      #bracket_fee = bracket_fee - ((personalized_discount.discount * bracket_fee) / 100)
    elsif general_discount.present? and general_discount.limit < general_discount.applied
      enroll_fee = enroll_fee - ((general_discount.discount * enroll_fee) / 100)
      #bracket_fee = bracket_fee - ((general_discount.discount * bracket_fee) / 100)
    end
    json_response_data({:enroll_fee => enroll_fee, :bracket_fee => bracket_fee, :tax => tax_amount})
  end

  private

  def resource_params
    # whitelist params
    params.permit(:venue_id, :event_type_id, :title, :icon, :description, :start_date, :end_date, :visibility,
                  :requires_access_code, :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
                  :is_determine_later_venue, :access_code)
  end

  def resource_icon_params
    # whitelist params
    params.permit(:icon)
  end

  def import_params
    # whitelist params
    params.permit(:file)
  end

  def venue_params
    # whitelist params
    params.permit(:name, :abbreviation, :country_code, :phone_number, :link, :facility, :description, :space, :latitude,
                  :longitude, :address_line_1, :address_line_2, :postal_code, :city, :state, :country, :availability_date_start,
                  :availability_date_end, :availability_time_zone, :restrictions, :is_insurance_requirements, :insurance_requirements,
                  :is_decorations, :decorations, :is_vehicles, :vehicles)
  end

  def facility_management_params
    # whitelist params
    unless params[:facility_management].nil?
      params.require(:facility_management).permit(:primary_contact_name, :primary_contact_email, :primary_contact_country_code, :primary_contact_phone_number,
                                                  :secondary_contact_name, :secondary_contact_email, :secondary_contact_country_code, :secondary_contact_phone_number)
    end
  end

  def payment_information_params
    # whitelist params
    unless params[:payment_information].nil?
      params.require(:payment_information).permit(:bank_name, :bank_account, :refund_policy, :service_fee, :app_fee, :bank_routing_number)
    end
  end

  def payment_method_params
    # whitelist params
    unless params[:payment_method].nil?
      params.require(:payment_method).permit(:enrollment_fee, :bracket_fee, :currency)
    end
  end

  def discounts_params
    # whitelist params
    unless params[:discounts].nil?
      params.require(:discounts).permit(:early_bird_registration, :early_bird_players, :early_bird_date_start, :early_bird_date_end,
                                        :late_registration, :late_players, :late_date_start, :late_date_end,
                                        :on_site_registration, :on_site_players, :on_site_date_start, :on_site_date_end)
    end

  end

  def discount_generals_params
    # whitelist params
    unless params[:discount_generals].nil? or params[:discount_generals].empty?
      #ActionController::Parameters.permit_all_parameters = true
      params.require(:discount_generals).map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :code, :discount, :limited)
      end
    end
    # ActionController::Parameters.permit_all_parameters = false
  end


  def discount_personalizeds_params
    # whitelist params
    unless params[:discount_personalizeds].nil? or params[:discount_personalizeds].empty?
      #ActionController::Parameters.permit_all_parameters = true
      params.require(:discount_personalizeds).map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :code, :discount, :email)
      end
    end
    #ActionController::Parameters.permit_all_parameters = false
  end

  def day_params
    # whitelist params
    params.permit(days: [:day, :time_start, :time_end])
  end

  def tax_params
    # whitelist params
    unless params[:tax].nil?
      params.require(:tax).permit(:tax, :code)
    end
  end

  def refund_policy_params
    # whitelist params
    unless params[:payment_information].nil?
      params.require(:payment_information).permit(:refund_policy)
    end
  end

  def service_fee_params
    # whitelist params
    unless params[:payment_information].nil?
      params.require(:payment_information).permit(:service_fee, :app_fee)
    end
  end

  def categories_params
    params.permit(categories: [])
  end

  def sports_params
    params.permit(sports: [])
  end

  def details_params
    params.permit(:elimination_format_id, :bracket_by, :scoring_option_match_1_id,
                  :scoring_option_match_2_id, :sport_regulator_id, :awards_for, :awards_through, :awards_plus)
  end

# params to brackets
  def bracket_params
    # whitelist params
    unless params[:brackets].nil?
      params[:brackets].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :event_bracket_id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity,
                                                               brackets: [:id, :event_bracket_id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity])
      end
    end
  end

  def agenda_params
    #validate presence and type
    unless params[:agendas].nil? and !params[:agendas].kind_of?(Array)
      params[:agendas].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :agenda_type_id, :category_id, :start_date, :end_date, :start_time,
                                                               :end_time)
      end
    end
  end

# search current resource of id
  def set_resource
    #apply policy scope
    @event = EventPolicy::Scope.new(current_user, Event).resolve.find(params[:id])
  end

  def response_message_error(message, code)
    json_response_error(message, 422, code)
  end

  def subscribe_params
    params.permit(:discount_code, :brackets_count)
  end
end
