class VenuesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
  around_action :transactions_filter, only: [:update, :create]

  swagger_path '/venues' do
    operation :get do
      key :summary, 'Get venues list'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesIndex'
      key :produces, ['application/json',]
      key :tags, ['venues']
      parameter do
        key :name, :name
        key :in, :query
        key :description, 'Name to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order special column "facility_management"'
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
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :sport_id
        key :in, :query
        key :description, 'Sport id to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :phone_number
        key :in, :query
        key :description, 'Phone number to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :facility
        key :in, :query
        key :description, 'Facility to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'State to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :city
        key :in, :query
        key :description, 'City to filter'
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
        key :name, :facility_management
        key :in, :query
        key :description, 'Facility management Yes/No filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Venue Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Venue
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
    authorize Venue
    column = params[:column].nil? ? 'name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    name = params[:name]
    sport_id = params[:sport_id]
    phone_number = params[:phone_number]
    facility = params[:facility]
    state = params[:state]
    city = params[:city]
    status = params[:status]
    facility_management_id = params[:facility_management_id]
    facility_management = params[:facility_management]
    column_facility_management = nil
    if column.to_s == "facility_management_id"
      column_facility_management = "primary_contact_name"
      column = nil
    end
    column_sports = nil
    if column.to_s == "sport_id"
      column_sports = "name"
      column = nil
    end
    venues = Venue.my_order(column, direction).name_like(name).sport_in(sport_id).phone_number_like(phone_number)
                 .is_facility(facility).state_like(state).city_like(city).is_status(status).facility_management_in(facility_management_id)
                 .facility_management_order(column_facility_management, direction).with_facility_management(facility_management)
                 .sports_order(column_sports, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(venues.all, VenueSerializer)
    else
      paginate venues, per_page: 50, root: :data
    end

  end
  swagger_path '/venues' do
    operation :post do
      key :summary, 'Create venue'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesCreate'
      key :produces, ['application/json',]
      key :tags, ['venues']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :abbreviation
        key :in, :body
        key :required, true
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
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :link
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :facility
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :description
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :space
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :latitude
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :longitude
        key :in, :body
        key :required, false
        key :type, :string
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
      parameter do
        key :name, :availability_date_start
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :date
      end
      parameter do
        key :name, :availability_date_end
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :date
      end
      parameter do
        key :name, :availability_time_zone
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :restrictions
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :is_insurance_requirements
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :insurance_requirements
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_decorations
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :is_vehicles
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :vehicles
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :days
        key :in, :body
        key :required, false
        key :type, :array
        items do
              key :'$ref', :VenueDayInput
        end
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
        key :name, :facility_management
        key :in, :body
        key :description, 'Facility management'
        schema do
          key :'$ref', :VenueFacilityManagementInput
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
    authorize Venue
    resource = Venue.create!(resource_params)
    if !params[:sports].nil?
      resource.sport_ids = params[:sports]
    end
    if !params[:facility_management].nil?
      resource.create_facility_management! facility_management_params
    end
    if params[:pictures]
      params[:pictures].each { |image|
        resource.pictures.create!(picture: image)
      }
    end
      if day_params[:days].present?
        resource.days.create!( day_params[:days])
      end
    json_response_success(t("created_success", model: Venue.model_name.human), true)
  end

  swagger_path '/venues/:id' do
    operation :get do
      key :summary, 'Show venue'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesShow'
      key :produces, ['application/json',]
      key :tags, ['venues']
      response 200 do
        key :description, 'Venues Respone'
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :Venue
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
    authorize Venue
    json_response_serializer(@venue, VenueSerializer)
  end
  swagger_path '/venues/:id' do
    operation :put do
      key :summary, 'Update venue'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesUpdate'
      key :produces, ['application/json',]
      key :tags, ['venues']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :abbreviation
        key :in, :body
        key :required, true
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
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :link
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :facility
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :description
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :space
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :latitude
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :longitude
        key :in, :body
        key :required, false
        key :type, :string
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
      parameter do
        key :name, :availability_date_start
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :date
      end
      parameter do
        key :name, :availability_date_end
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :date
      end
      parameter do
        key :name, :availability_time_zone
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :restrictions
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :is_insurance_requirements
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :insurance_requirements
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :is_decorations
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :is_vehicles
        key :in, :body
        key :required, false
        key :type, :boolean
      end
      parameter do
        key :name, :vehicles
        key :in, :body
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :days
        key :in, :body
        key :required, false
        key :type, :array
        items do
            key :'$ref', :VenueDayInput
        end
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
        key :name, :facility_management
        key :in, :body
        key :description, 'Facility management'
        schema do
          key :'$ref', :VenueFacilityManagementInput
        end
      end
      parameter do
        key :name, :deleted_images
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
    authorize Venue
    if !params[:facility_management].nil?
      @venue.create_facility_management! facility_management_params
    end
    if !params[:sports].nil?
      @venue.sport_ids = params[:sports]
    end
    if day_params[:days].present?
        @venue.days.destroy_all
        @venue.days.create!( day_params[:days])
    end
    if params[:deleted_images]
      @venue.pictures.where(id: params[:deleted_images]).destroy_all
    end
    if params[:pictures]
      params[:pictures].each { |image|
        @venue.pictures.create!(picture: image)
      }
    end
    @venue.update!(resource_params)
    json_response_success(t("edited_success", model: Venue.model_name.human), true)
  end
  swagger_path '/venues/:id' do
    operation :delete do
      key :summary, 'Delete venue'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesDelete'
      key :produces, ['application/json',]
      key :tags, ['venues']
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
    authorize Venue
    @venue.destroy
    json_response_success(t("deleted_success", model: Venue.model_name.human), true)
  end
  swagger_path '/venues/:id/activate' do
    operation :put do
      key :summary, 'Activate venue'
      key :description, 'Venues Catalog'
      key :operationId, 'venuesActivate'
      key :produces, ['application/json',]
      key :tags, ['venues']
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
    authorize Venue
    @venue.status = :Active
    @venue.save!(:validate => false)
    json_response_success(t("activated_success", model: Venue.model_name.human), true)
  end
  swagger_path '/venues/:id/inactive' do
    operation :put do
      key :summary, 'Activate venue'
      key :description, 'Inactivate Catalog'
      key :operationId, 'venuesInactivate'
      key :produces, ['application/json',]
      key :tags, ['venues']
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
    authorize Venue
    @venue.status = :Inactive
    @venue.save!(:validate => false)
    json_response_success(t("inactivated_success", model: Venue.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name, :abbreviation, :country_code, :phone_number, :link, :facility, :description, :space, :latitude,
                  :longitude, :address_line_1, :address_line_2, :postal_code, :city, :state, :country, :availability_date_start,
                  :availability_date_end, :availability_time_zone, :restrictions, :is_insurance_requirements, :insurance_requirements,
                  :is_decorations, :decorations, :is_vehicles, :vehicles)
  end

  def day_params
    # whitelist params
    params.permit(days: [:day, :time_start, :time_end] )
  end

  def facility_management_params
    # whitelist params
    params.require(:facility_management).permit(:primary_contact_name, :primary_contact_email, :primary_contact_country_code, :primary_contact_phone_number,
                                                :secondary_contact_name, :secondary_contact_email, :secondary_contact_country_code, :secondary_contact_phone_number)
  end

  def set_resource
    @venue = Venue.find(params[:id])
  end
end
