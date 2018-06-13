class EventsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :create_venue, :payment_information,
                                      :payment_method, :discounts, :import_discount_personalizeds, :tax, :refund_policy,
                                      :service_fee, :registration_rule, :venue, :details]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:update, :create, :create_venue, :discounts, :import_discount_personalizeds,
                                             :details, :activate]


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

  def index
    authorize Event

    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]

    title = params[:title]
    start_date = params[:start_date]
    status = params[:status]


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
    paginate EventPolicy::Scope.new(current_user, Event).resolve.my_order(column, direction).venue_order(column_venue, direction).sport_in(sport_id).sports_order(column_sports, direction).title_like(title)
                 .start_date_like(start_date).in_status(status).state_like(state).city_like(city), per_page: 50, root: :data
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

  def show
    authorize Event
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
    payment_method = @event.payment_method
    if payment_method.present?
      payment_method.update!(payment_method_params)
    else
      @event.create_payment_method!(payment_method_params)
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
    discount = @event.discount
    if discounts_params.present?
      if discount.present?
        discount.update!(discounts_params)
      else
        @event.create_discount!(discounts_params)
      end
    end
    if discount_generals_params.present?
      @event.sync_discount_generals! discount_generals_params
    end
    if discount_personalizeds_params.present?
      @event.sync_discount_personalizeds! discount_personalizeds_params
    end
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
    tax = @event.tax
    if tax.present?
      tax.update! tax_params
    else
      @event.create_tax! tax_params
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
        key :name, :refund_policy
        key :in, :body
        key :description, 'Refund policy'
        key :type, :string
        key :required, true
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
    information = @event.payment_information
    if information.present?
      information.update!(refund_policy_params)
    else
      @event.create_payment_information!(refund_policy_params)
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
        key :name, :service_fee
        key :in, :body
        key :description, 'Service fee'
        key :required, true
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

  def service_fee
    authorize Event
    information = @event.payment_information
    if information.present?
      information.update!(service_fee_params)
    else
      @event.create_payment_information!(service_fee_params)
    end
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/registration_rule' do
    operation :put do
      key :summary, 'Events registration rule'
      key :description, 'Events Catalog'
      key :operationId, 'eventsRegistrationRule'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :registration_rule
        key :in, :body
        key :description, 'Registration rule'
        key :required, true
        schema do
          key :'$ref', :EventRegistrationRuleInput
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

  def registration_rule
    authorize Event
    registration_rule = @event.registration_rule
    if registration_rule.present?
      registration_rule.update! registration_rule_params
    else
      @event.create_registration_rule! registration_rule_params
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
        key :name, :bracket_ages
        key :in, :body
        key :description, 'Bracket ages'
        key :type, :array
        items do
          key :'$ref', :EventBracketAgeInput
        end
      end
      parameter do
        key :name, :bracket_skills
        key :in, :body
        key :description, 'Bracket ages'
        key :type, :array
        items do
          key :'$ref', :EventBracketSkillInput
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

  def details
    authorize Event
    unless categories_params[:categories].nil?
      @event.category_ids = categories_params[:categories]
    end
    @event.update! details_params
    @event.sync_bracket_age! bracket_ages_params
    @event.sync_bracket_skill! bracket_skills_params
    json_response_serializer(@event, EventSerializer)
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
    params.require(:facility_management).permit(:primary_contact_name, :primary_contact_email, :primary_contact_country_code, :primary_contact_phone_number,
                                                :secondary_contact_name, :secondary_contact_email, :secondary_contact_country_code, :secondary_contact_phone_number)
  end

  def payment_information_params
    # whitelist params
    params.require(:payment_information).permit(:bank_name, :bank_account, :refund_policy, :service_fee)
  end

  def payment_method_params
    # whitelist params
    params.require(:payment_method).permit(:enrollment_fee, :bracket_fee, :currency)
  end

  def discounts_params
    # whitelist params
    unless params[:discounts].nil?
      params.require(:discounts).permit(:early_bird_registration, :early_bird_players, :late_registration, :late_players,
                                        :on_site_registration, :on_site_players)
    end

  end

  def discount_generals_params
    # whitelist params
    unless params[:discount_generals].nil?
      #ActionController::Parameters.permit_all_parameters = true
      params.require(:discount_generals).map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :code, :discount, :limited)
      end
    end
    # ActionController::Parameters.permit_all_parameters = false
  end


  def discount_personalizeds_params
    # whitelist params
    unless params[:discount_personalizeds].nil?
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
    params.require(:tax).permit(:tax)
  end

  def refund_policy_params
    # whitelist params
    params.require(:payment_information).permit(:refund_policy)
  end

  def service_fee_params
    # whitelist params
    params.require(:payment_information).permit(:service_fee)
  end

  def registration_rule_params
    # whitelist params
    params.require(:registration_rule).permit(:allow_group_registrations, :partner, :require_password,
                                              :password, :require_director_approval, :allow_players_cancel,:use_link_home_page,
                                              :link_homepage, :use_link_event_website, :link_event_website, :use_app_event_website, :link_app)
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

  def bracket_ages_params
    # whitelist params
    #ActionController::Parameters.permit_all_parameters = true
    unless params[:bracket_ages].nil?
      params[:bracket_ages].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :event_bracket_skill_id, :age, :quantity,
                                                               bracket_skills: [:id, :event_bracket_age_id, :lowest_skill, :highest_skill, :quantity])
      end
    end
    #ActionController::Parameters.permit_all_parameters = false
  end

  def bracket_skills_params
    # whitelist params
    #ActionController::Parameters.permit_all_parameters = true
    unless params[:bracket_skills].nil? and !params[:bracket_skills].kind_of?(Array)
      params[:bracket_skills].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :event_bracket_age_id, :lowest_skill, :highest_skill, :quantity,
                                                               bracket_ages: [:id, :event_bracket_skill_id, :age, :quantity])
      end
    end
    #ActionController::Parameters.permit_all_parameters = false
  end

  def set_resource
    @event = EventPolicy::Scope.new(current_user, Event).resolve.find(params[:id])
  end
end
