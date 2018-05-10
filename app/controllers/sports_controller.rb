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

      response 200 do
        key :description, ''
        schema do
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
    json_response_data(Sport.all, :created)
    #paginate Sport.unscoped, per_page: 50
  end

  def create
    resource = Sport.create!(resource_params)
    json_response_data(resource, :created)
  end

  def show
    json_response_data(@resource)
  end

  def update
    @resource.update!(resource_params)
    json_response_data(@resource, :updated)
  end

  def destroy
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
