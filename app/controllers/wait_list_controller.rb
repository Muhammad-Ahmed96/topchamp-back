class WaitListController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]
  before_action :set_event, only: [ :create, :index]
  swagger_path '/events/:event_id/wait_list' do
    operation :post do
      key :summary, 'Save wait list'
      key :description, 'Event Catalog'
      key :operationId, 'waitListSave'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :wait_list
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :'$ref', :WaitListInput
        end
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
  def create
    if wait_list_params.present?
      @resource.sync_wait_list(wait_list_params, @event.id)
      return json_response_success(t("success"), true)
    else
      return response_no_enroll_error
    end

  end
  swagger_path '/events/:event_id/wait_list' do
    operation :get do
      key :summary, 'Wait list '
      key :description, 'Event Catalog'
      key :operationId, 'waitListIndex'
      key :produces, ['application/json',]
      key :tags, ['events']
      response 200 do
        schema do
          property :data do
            items do
              key :'$ref', :WaitList
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
    json_response_serializer_collection(@resource.wait_lists.where(:event_id => @event.id), WaitListSerializer)
  end

  private
  def wait_list_params
    unless params[:wait_list].nil? and !params[:wait_list].kind_of?(Array)
      params[:wait_list].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_id)
      end
    end
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def response_no_enroll_error
    json_response_error([t("not_brackets_to_enrroll")], 422)
  end
end
