class AgendaTypesController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  swagger_path '/agenda_types' do
    operation :get do
      key :summary, 'Get agenda type list'
      key :description, 'Agenda types Catalog'
      key :operationId, 'agendaTypeIndex'
      key :produces, ['application/json',]
      key :tags, ['agenda type']
      parameter do
        key :name, :search
        key :in, :query
        key :description, 'Keyword to search'
        key :required, false
        key :type, :string
      end
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
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :PaginateModel
          property :data do
            items do
              key :'$ref', :AgendaType
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
    authorize AgendaType
    search = params[:search].strip unless params[:search].nil?
    column = params[:column].nil? ? 'name': params[:column]
    direction = params[:direction].nil? ? 'asc': params[:direction]
    paginate AgendaType.my_order(column, direction).search(search), per_page: 50, root: :data
  end
=begin
  swagger_path '/agenda_types' do
    operation :post do
      key :summary, 'Create a agenda type'
      key :description, 'Agenda types Catalog'
      key :operationId, 'agendaTypeCreate'
      key :produces, ['application/json',]
      key :tags, ['agenda type']
      parameter do
        key :name, :name
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
    authorize AgendaType
    resource = AgendaType.create!(resource_params)
    json_response_success(t("created_success", model: AgendaType.model_name.human), true)
  end

=begin
  swagger_path '/agenda_types/:id' do
    operation :get do
      key :summary, 'Show a agenda type'
      key :description, 'Agenda types Catalog'
      key :operationId, 'agendaTypeShow'
      key :produces, ['application/json',]
      key :tags, ['agenda type']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :AgendaType
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
    authorize AgendaType
    json_response_serializer(@agendaType, AgendaTypeSerializer)
  end

=begin
  swagger_path '/agenda_types/:id' do
    operation :put do
      key :summary, 'Edit a agenda type'
      key :description, 'Agenda types Catalog'
      key :operationId, 'agendaTypeUpdate'
      key :produces, ['application/json',]
      key :tags, ['agenda type']
      parameter do
        key :name, :name
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
    authorize AgendaType
    @agendaType.update!(resource_params)
    json_response_success(t("edited_success", model: AgendaType.model_name.human), true)
  end

=begin
  swagger_path '/agenda_types/:id' do
    operation :delete do
      key :summary, 'Delete a agenda type'
      key :description, 'Agenda types Catalog'
      key :operationId, 'agendaTypeDelete'
      key :produces, ['application/json',]
      key :tags, ['agenda type']
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
    authorize AgendaType
    @agendaType.destroy
    json_response_success(t("deleted_success", model: AgendaType.model_name.human), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name)
  end
  def set_resource
    @agendaType = AgendaType.find(params[:id])
  end
end
