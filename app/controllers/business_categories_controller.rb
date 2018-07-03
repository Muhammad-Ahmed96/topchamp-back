class BusinessCategoriesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/business_categories' do
    operation :get do
      key :summary, 'Get business categories'
      key :description, 'Business categories Catalog'
      key :operationId, 'businessCategoriesIndex'
      key :produces, ['application/json',]
      key :tags, ['business_categories']
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
    column = params[:column].nil? ? 'description' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    search = params[:search].strip unless params[:search].nil?
    description = params[:description].strip unless params[:description].nil?
    code = params[:code].strip unless params[:code].nil?
    group = params[:group].strip unless params[:group].nil?
    business_categories= BusinessCategory.my_order(column, direction).search(search).description_like(description)
    .code_like(code).group_like(group)
    if paginate.to_s == "0"
      json_response_serializer_collection(business_categories.all, BusinessCategorySerializer)
    else
      paginate business_categories, per_page: 50, root: :data
    end
  end
end
