class AttendeeTypeController < ApplicationController
  include Swagger::Blocks
    before_action :set_resource, only: [:show, :update, :destroy]
    before_action :authenticate_user!
    swagger_path '/attendee_type' do
      operation :get do
        key :summary, 'Get attendee type list'
        key :description, 'Attendee type Catalog'
        key :operationId, 'attendeeTypeIndex'
        key :produces, ['application/json',]
        key :tags, ['attendee type']
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
                key :'$ref', :AttendeeType
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
      authorize AttendeeType
      search = params[:search].strip unless params[:search].nil?
      column = params[:column].nil? ? 'name': params[:column]
      direction = params[:direction].nil? ? 'asc': params[:direction]
      paginate AttendeeType.my_order(column, direction).search(search), per_page: 50, root: :data
    end
=begin
  swagger_path '/attendee_type' do
    operation :post do
      key :summary, 'Create a attendee type'
      key :description, 'Attendee type Catalog'
      key :operationId, 'attendeeTypeCreate'
      key :produces, ['application/json',]
      key :tags, ['attendee type']
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
      authorize AttendeeType
      resource = AttendeeType.create!(resource_params)
      json_response_success(t("created_success", model: AttendeeType.model_name.human), true)
    end
=begin
  swagger_path '/attendee_type/:id' do
    operation :get do
      key :summary, 'Show a attendee type'
      key :description, 'Attendee type Catalog'
      key :operationId, 'attendeeTypeShow'
      key :produces, ['application/json',]
      key :tags, ['attendee type']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :AttendeeType
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
      authorize AttendeeType
      json_response_serializer(@attendeeType, AttendeeTypeSerializer)
    end
=begin
  swagger_path '/attendee_type/:id' do
    operation :put do
      key :summary, 'Edit a attendee type'
      key :description, 'Attendee type Catalog'
      key :operationId, 'attendeeTypeUpdate'
      key :produces, ['application/json',]
      key :tags, ['attendee type']
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
      authorize AttendeeType
      @attendeeType.update!(resource_params)
      json_response_success(t("edited_success", model: AttendeeType.model_name.human), true)
    end
=begin
  swagger_path '/attendee_type/:id' do
    operation :delete do
      key :summary, 'Delete a attendee type'
      key :description, 'Attendee type Catalog'
      key :operationId, 'attendeeTypeDelete'
      key :produces, ['application/json',]
      key :tags, ['attendee type']
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
      authorize AttendeeType
      @attendeeType.destroy
      json_response_success(t("deleted_success", model: AttendeeType.model_name.human), true)
    end

    private

    def resource_params
      # whitelist params
      params.permit(:name)
    end
    def set_resource
      @attendeeType = AttendeeType.find(params[:id])
    end
end
