class CategoriesController < ApplicationController
  include Swagger::Blocks
  swagger_path '/categories' do
    operation :get do
      key :summary, 'Get categories list'
      key :description, 'Categories Catalog'
      key :operationId, 'categoryIndex'
      key :produces, ['application/json',]
      key :tags, ['category']
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :'$ref', :Category
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
    json_response_serializer_collection(Category.all, CategorySerializer)
  end
end
