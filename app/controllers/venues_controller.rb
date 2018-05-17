class VenuesController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
  before_action :authenticate_user!

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
        key :name, :facility_management_id
        key :in, :query
        key :description, 'Facility management id filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :Venue
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
    column = params[:column].nil? ? 'name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]

    name = params[:name]
    sport_id = params[:sport_id]
    phone_number = params[:phone_number]
    facility = params[:facility]
    state = params[:state]
    city = params[:city]
    status = params[:status]
    facility_management_id = params[:facility_management_id]
    column_facility_management = nil
    if column.to_s == "facility_management"
      column_facility_management = column
      column = nil
    end
    paginate Venue.unscoped.my_order(column, direction).name_like(name).sport_in(sport_id).phone_number_like(phone_number)
      .is_facility(facility).state_like(state).city_like(city).is_status(status).facility_management_in(facility_management_id)
                 .facility_management_order(column_facility_management), per_page: 50, root: :data
  end

  def create
    authorize Venue
    resource = Venue.create!(resource_params)
    if !params[:sports].nil?
      resource.sport_ids = params[:sports]
    end
    if !params[:facility_management].nil?
      resource.create_facility_managements! facility_management_params
    end
    if params[:pictures]
      params[:pictures].each { |image|
        resource.pictures.create(picture: image)
      }
    end
      if day_params[:days].present?
        resource.days.create!( day_params[:days])
      end
    json_response_success(t("created_success", model: Venue.model_name.human), true)
  end

  def show
    authorize Venue
    json_response_data(@venue)
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
    if params[:pictures]
      @venue.pictures.destroy_all
      params[:pictures].each { |image|
        @venue.pictures.create!(picture: image)
      }
    end
    @venue.update!(resource_params)
    json_response_success(t("edited_success", model: Venue.model_name.human), true)
  end

  def destroy
    authorize Venue
    @venue.destroy
    json_response_success(t("deleted_success", model: Venue.model_name.human), true)
  end

  def activate
    authorize Venue
    @venue.status = :Active
    @venue.save
    json_response_success(t("activated_success", model: Venue.model_name.human), true)
  end

  def inactive
    authorize Venue
    @venue.status = :Inactive
    @venue.save
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
    params.permit(days: [:day, :time] )
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
