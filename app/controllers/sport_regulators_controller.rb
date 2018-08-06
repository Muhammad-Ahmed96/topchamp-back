class SportRegulatorsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/sport_regulators' do
    operation :get do
      key :summary, 'Get sport regulators list'
      key :description, 'Sport regulators Catalog'
      key :operationId, 'sportRegulatorsIndex'
      key :produces, ['application/json',]
      key :tags, ['sport_regulators']
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
        key :description, 'Sport Regulator Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :SportRegulator
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
    authorize SportRegulator
    #json_response_data(Sport.all, :created)
    column = params[:column].nil? ? 'index' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    search = params[:search].strip unless params[:search].nil?
    sportRegulator = SportRegulator.my_order(column, direction).search(search)
    if paginate.to_s == "0"
      json_response_serializer_collection(sportRegulator.all, SportSerializer)
    else
      paginate sportRegulator, per_page: 50, root: :data
    end
  end
end
