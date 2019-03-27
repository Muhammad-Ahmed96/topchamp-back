class RegionsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:show, :update, :destroy]
  swagger_path '/regions' do
    operation :get do
      key :summary, 'Get region list'
      key :description, 'Regions Catalog'
      key :operationId, 'regionIndex'
      key :produces, ['application/json',]
      key :tags, ['region']
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
        key :name, :name
        key :in, :query
        key :description, 'Name to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :base
        key :in, :query
        key :description, 'Base to filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :territory
        key :in, :query
        key :description, 'Territory to filter'
        key :required, false
        key :type, :string
      end

      response 200 do
        key :description, 'Region Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Region
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
    authorize Region
    column = params[:column].nil? ? 'name': params[:column]
    direction = params[:direction].nil? ? 'asc': params[:direction]

    name = params[:name].strip unless params[:name].nil?
    base = params[:base].strip unless params[:base].nil?
    territory = params[:territory].strip unless params[:territory].nil?
    paginate Region.my_order(column, direction).name_like(name).base_like(base).territory_like(territory), per_page: 50, root: :data
  end
=begin
  swagger_path '/regions' do
    operation :post do
      key :summary, 'Create a region'
      key :description, 'Regions Catalog'
      key :operationId, 'regionCreate'
      key :produces, ['application/json',]
      key :tags, ['region']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :base
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :territory
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
    authorize Region
    resource = Region.create!(resource_params)
    json_response_success(t("created_success", model: Region.model_name.human), true)
  end

=begin
  swagger_path '/regions/:id' do
    operation :get do
      key :summary, 'Show a region'
      key :description, 'Regions Catalog'
      key :operationId, 'regionShow'
      key :produces, ['application/json',]
      key :tags, ['region']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :Region
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
    authorize Region
    json_response_serializer(@region, RegionSerializer)
  end

=begin
  swagger_path '/regions/:id' do
    operation :put do
      key :summary, 'Edit a region'
      key :description, 'Regions Catalog'
      key :operationId, 'regionUpdate'
      key :produces, ['application/json',]
      key :tags, ['region']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :base
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :territory
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
    authorize Region
    @region.update!(resource_params)
    json_response_success(t("edited_success", model: Region.model_name.human), true)
  end


=begin
  swagger_path '/regions/:id' do
    operation :delete do
      key :summary, 'Delete a region'
      key :description, 'Regions Catalog'
      key :operationId, 'regionDelete'
      key :produces, ['application/json',]
      key :tags, ['region']
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
    authorize Region
    @region.destroy
    json_response_success(t("deleted_success", model: Region.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name, :base, :territory)
  end
  def set_resource
    @region = Region.find(params[:id])
  end
end
