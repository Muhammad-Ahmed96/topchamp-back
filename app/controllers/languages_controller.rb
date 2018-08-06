class LanguagesController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  swagger_path '/languages' do
    operation :get do
      key :summary, 'Get language list'
      key :description, 'Languages Catalog'
      key :operationId, 'languageIndex'
      key :produces, ['application/json',]
      key :tags, ['language']
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
        key :name, :locale
        key :in, :query
        key :description, 'Locale to filter'
        key :required, false
        key :type, :string
      end
      response 200 do
        key :description, 'Language Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Language
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
    authorize Language
    column = params[:column].nil? ? 'name': params[:column]
    direction = params[:direction].nil? ? 'asc': params[:direction]

    name = params[:name].strip unless params[:name].nil?
    locale = params[:locale].strip unless params[:locale].nil?
    paginate Language.my_order(column, direction).name_like(name).locale_like(locale), per_page: 50, root: :data
  end
=begin
  swagger_path '/languages' do
    operation :post do
      key :summary, 'Create a language'
      key :description, 'Languages Catalog'
      key :operationId, 'languageCreate'
      key :produces, ['application/json',]
      key :tags, ['language']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :locale
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
    authorize Language
    resource = Language.create!(resource_params)
    json_response_success(t("created_success", model: Language.model_name.human), true)
  end

=begin
  swagger_path '/languages/:id' do
    operation :get do
      key :summary, 'Show a language'
      key :description, 'Languages Catalog'
      key :operationId, 'languageShow'
      key :produces, ['application/json',]
      key :tags, ['language']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :Language
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
    authorize Language
    json_response_serializer(@language, LanguageSerializer)
  end

=begin
  swagger_path '/languages/:id' do
    operation :put do
      key :summary, 'Edit a language'
      key :description, 'Languages Catalog'
      key :operationId, 'languageUpdate'
      key :produces, ['application/json',]
      key :tags, ['language']
      parameter do
        key :name, :name
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :locale
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
    authorize Language
    @language.update!(resource_params)
    json_response_success(t("edited_success", model: Language.model_name.human), true)
  end

=begin
  swagger_path '/languages/:id' do
    operation :delete do
      key :summary, 'Delete a language'
      key :description, 'Languages Catalog'
      key :operationId, 'languageDelete'
      key :produces, ['application/json',]
      key :tags, ['language']
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
    authorize Language
    @language.destroy
    json_response_success(t("deleted_success", model: Language.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name, :locale)
  end
  def set_resource
    @language = Language.find(params[:id])
  end
end
