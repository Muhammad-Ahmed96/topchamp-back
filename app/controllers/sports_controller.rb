class SportsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy]
  swagger_path '/sports' do
    operation :get do
      key :summary, 'Get sports list'
      key :description, 'Sports Catalog'
      key :operationId, 'sportsIndex'
      key :produces, ['application/json',]
      key :tags, ['sports']
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
        key :description, 'Direction to order, (ASC or DESC)'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :Sport
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
    authorize Sport
    #json_response_data(Sport.all, :created)
    column = params[:column].nil? ? 'name' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate Sport.unscoped.my_order(column, direction), per_page: 50
  end

  def create
    authorize Sport
    resource = Sport.create!(resource_params)
    json_response_data(resource, :created)
  end

  def show
    authorize Sport
    json_response_data(@resource)
  end

  def update
    authorize Sport
    @resource.update!(resource_params)
    json_response_data(@resource, :updated)
  end

  def destroy
    authorize Sport
    @resource.destroy
    json_response_success(t(:deleted), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name)
  end

  def set_resource
    @resource = Sport.find(params[:id])
  end
end
