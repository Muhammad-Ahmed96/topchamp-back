class EliminationFormatsController < ApplicationController
  include Swagger::Blocks
    swagger_path '/elimination_formats' do
      operation :get do
        key :summary, 'Get elimination formats list'
        key :description, 'Elimination formats Catalog'
        key :operationId, 'eliminationFormatsIndex'
        key :produces, ['application/json',]
        key :tags, ['elimination_formats']
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
                key :'$ref', :EliminationFormat
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
      authorize EliminationFormat
      #json_response_data(Sport.all, :created)
      column = params[:column].nil? ? 'index' : params[:column]
      direction = params[:direction].nil? ? 'asc' : params[:direction]
      paginate = params[:paginate].nil? ? '1' : params[:paginate]
      search = params[:search].strip unless params[:search].nil?
      eliminationFormat = EliminationFormat.my_order(column, direction).search(search)
      if paginate.to_s == "0"
        json_response_serializer_collection(eliminationFormat.all, EliminationFormatSerializer)
      else
        paginate eliminationFormat, per_page: 50, root: :data
      end
    end
end
