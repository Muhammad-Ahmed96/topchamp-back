class SponsorsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy, :activate, :inactive]
  before_action :authenticate_user!
=begin
  swagger_path '/sponsors' do
    operation :get do
      key :summary, 'Get sponsor list'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorIndex'
      key :produces, ['application/json',]
      key :tags, ['sponsor']
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
      parameter do
        key :name, :company_name
        key :in, :query
        key :description, 'Company name to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :brand
        key :in, :query
        key :description, 'Brand to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :product
        key :in, :query
        key :description, 'Product to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :franchise_brand
        key :in, :query
        key :description, 'Franchise brand to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :business_category
        key :in, :query
        key :description, 'Business category to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :state
        key :in, :query
        key :description, 'state to filter'
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
        key :name, :geography
        key :in, :query
        key :description, 'Geography to filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :Sponsor
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
    authorize Sponsor
    column = params[:column].nil? ? 'company_name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]

    company_name = params[:company_name]
    brand = params[:brand]
    product = params[:product]
    franchise_brand = params[:franchise_brand]
    business_category = params[:business_category]
    state = params[:state]
    city = params[:city]
    status = params[:status]
    geography = params[:geography]
    paginate Sponsor.unscoped.my_order(column, direction).in_status(status).in_geography(geography).company_name_like(company_name)
                 .brand_like(brand).product_like(product).franchise_brand_like(franchise_brand).business_category_like(business_category)
                 .state_like(state).city_like(city), per_page: 50, root: :data
  end
=begin
  swagger_path '/sponsors' do
    operation :post do
      key :summary, 'Create sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorCreate'
      key :produces, ['application/json',]
      key :tags, ['sponsor']

      parameter do
        key :name, :company_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :logo
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :brand
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :product
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :franchise_brand
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :business_category
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :geography
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
        key :name, :contact_name
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
        key :name, :phone
        key :in, :body
        key :required, true
        key :type, :string
      end

      parameter do
        key :name, :email
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :address_line_1
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :address_line_2
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
        key :name, :city
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :work_country_code
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :work_phone
        key :in, :body
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
=end
  def create
    authorize Sponsor
    resource = Sponsor.create!(resource_params)
    json_response_success(t("created_success", model: Sponsor.model_name.human), true)
  end
=begin
  swagger_path '/sponsors/:id' do
    operation :get do
      key :summary, 'Show sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorShow'
      key :produces, ['application/json',]
      key :tags, ['sponsor']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :Sponsor
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
    authorize Sponsor
    json_response_serializer(@sponsor, SponsorSerializer)
  end
=begin
  swagger_path '/sponsors/:id' do
    operation :put do
      key :summary, 'Update sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorUpdate'
      key :produces, ['application/json',]
      key :tags, ['sponsor']

      parameter do
        key :name, :company_name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :logo
        key :in, :body
        key :required, false
        key :type, :file
      end
      parameter do
        key :name, :brand
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :product
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :franchise_brand
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :business_category
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :geography
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
        key :name, :contact_name
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
        key :name, :phone
        key :in, :body
        key :required, true
        key :type, :string
      end

      parameter do
        key :name, :email
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :address_line_1
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :address_line_2
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
        key :name, :city
        key :in, :body
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :work_country_code
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :work_phone
        key :in, :body
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
=end
  def update
    authorize Sponsor
    @sponsor.update!(resource_params)
    json_response_success(t("edited_success", model: Sponsor.model_name.human), true)
  end
=begin
  swagger_path '/sponsors/:id' do
    operation :delete do
      key :summary, 'Delete sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorDelete'
      key :produces, ['application/json',]
      key :tags, ['sponsor']
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
    authorize Sponsor
    @sponsor.destroy
    json_response_success(t("deleted_success", model: Sponsor.model_name.human), true)
  end
=begin
  swagger_path '/sponsors/:id/activate' do
    operation :put do
      key :summary, 'Activate sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorActivate'
      key :produces, ['application/json',]
      key :tags, ['sponsor']
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
  def activate
    authorize Sponsor
    @sponsor.status = :Active
    @sponsor.save
    json_response_success(t("activated_success", model: Sponsor.model_name.human), true)
  end
=begin
  swagger_path '/sponsors/:id/inactive' do
    operation :put do
      key :summary, 'Inactive sponsor'
      key :description, 'Sponsor Catalog'
      key :operationId, 'sponsorInactive'
      key :produces, ['application/json',]
      key :tags, ['sponsor']
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
  def inactive
    authorize Sponsor
    @sponsor.status = :Inactive
    @sponsor.save
    json_response_success(t("inactivated_success", model: Sponsor.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:company_name, :logo, :brand, :product, :franchise_brand, :business_category, :geography, :description, :contact_name,
                  :country_code, :phone, :email, :address_line_1, :address_line_2, :postal_code, :state, :city, :work_country_code,
                  :work_phone)
  end

  def set_resource
    @sponsor = Sponsor.find(params[:id])
  end
end
