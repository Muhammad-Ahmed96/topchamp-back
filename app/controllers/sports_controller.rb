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
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
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
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    search = params[:search].strip unless params[:search].nil?
    sports = Sport.my_order(column, direction).search(search)
    if paginate.to_s == "0"
      json_response_serializer_collection(sports.all, SportSerializer)
    else
      paginate sports, per_page: 50, root: :data
    end
  end

  def create
    authorize Sport
    @sport = Sport.create!(resource_params)
    json_response_success(t("created_success", model: Sport.model_name.human), true)
  end

  def show
    authorize Sport
    json_response_serializer(@sport, SportSerializer)
  end

  def update
    authorize Sport
    @sport.update!(resource_params)
    json_response_success(t("edited_success", model: Sport.model_name.human), true)
  end

  def destroy
    authorize Sport
    @sport.destroy
    json_response_success(t("deleted_success", model: Sport.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name)
  end

  def set_resource
    @sport = Sport.find(params[:id])
  end
end
