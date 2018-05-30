class EventsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive, :create_venue, :payment_information,
                                      :payment_method, :discounts, :import_discount_personalizeds, :tax, :refund_policy,
                                      :service_fee, :registration_rule, :venue]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:update, :create, :create_venue, :discounts, :import_discount_personalizeds]
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

  def create
    authorize Event
    @event = Event.create!(resource_params)
    if !params[:sports].nil?
      @event.sport_ids = params[:sports]
    end
    if !params[:regions].nil?
      @event.region_ids = params[:regions]
    end
    json_response_serializer(@event, EventSerializer)
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
    json_response_serializer(@event, EventSerializer)
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

  def create_venue
    authorize Event
    venue = Venue.create!(venue_params)
    @event.venue_id = venue.id
    @event.save
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

  def venue
    authorize Event
    if params[:is_determine_later_venue].present? and  (params[:is_determine_later_venue].equal?(true) or params[:is_determine_later_venue].to_s =="1"  )
      @event.is_determine_later_venue = true
      @event.venue_id = nil
      @event.save
      json_response_serializer(@event, EventSerializer)
    else
      if params[:venue_id].present?
        @event.venue_id = params[:venue_id]
        @event.save
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

  def activate
    authorize Event
    @event.status = :Active
    @event.save
    json_response_serializer(@event, EventSerializer)
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

  def inactive
    authorize Event
    @event.status = :Inactive
    @event.save
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

  def discounts
    authorize Event
    discount = @event.discount
    if discount.present?
      discount.update!(discounts_params)
    else
      @event.create_discount!(discounts_params)
    end
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

  def import_discount_personalizeds
    authorize Event
    @event.import_discount_personalizeds!(import_params[:file])
    json_response_serializer(@event, EventSerializer)
  end

  swagger_path '/events/:id/tax' do
    operation :put do
      key :summary, 'Events import discount personalizeds '
      key :description, 'Events Catalog'
      key :operationId, 'eventsImportDiscountPersonalizeds'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :tax
        key :in, :body
        key :description, 'Taxes'
        key :'$ref', :EventTaxInput
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
=begin
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
        key :'$ref', :EventRegistrationRuleInput
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
    params.require(:discounts).permit(:early_bird_registration, :early_bird_players, :late_registration, :late_players,
                                      :on_site_registration, :on_site_players)
  end

  def discount_generals_params
    # whitelist params
    ActionController::Parameters.permit_all_parameters = true
    params.require(:discount_generals).map do |p|
      ActionController::Parameters.new(p.to_hash).permit(:id, :code, :discount, :limited)
    end
  end


  def discount_personalizeds_params
    # whitelist params
    ActionController::Parameters.permit_all_parameters = true
    params.require(:discount_personalizeds).map do |p|
      ActionController::Parameters.new(p.to_hash).permit(:id, :code, :discount, :email)
    end
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
    params.require(:registration_rule).permit(:allow_group_registrations, :partner, :require_password, :anyone_require_password,
                                              :password, :require_director_approval, :allow_players_cancel, :link_homepage,
                                              :link_event_website, :use_app_event_website, :link_app)
  end

  def set_resource
    @event = Event.find(params[:id])
  end
end
