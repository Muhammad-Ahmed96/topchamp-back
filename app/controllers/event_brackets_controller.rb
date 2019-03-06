class EventBracketsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:available]
  swagger_path '/events/:event_id/event_brackets/available' do
    operation :get do
      key :summary, 'Show available brackets to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventBracketAvailableIndex'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :description, 'event id'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :description, 'category id'
        key :required, true
        key :type, :integer
      end
      response 200 do
        key :description, 'Event Brackets'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :EventBracket
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
  def available
    used_ids = Tournament.where(:event_id => @event.id).where(:category_id => index_params[:category_id]).pluck(:event_bracket_id)
    event_brackets = EventContestCategoryBracketDetail.where(:event => @event.id).where.not(:id => used_ids)#@event.brackets.where.not(:id => used_ids)
    json_response_serializer_collection(event_brackets, EventContestCategoryBracketDetailSerializer)
  end

  private
  def index_params
    params.required(:category_id)
    params.permit(:category_id, :contest_id)
  end
  def set_resource
    @event = Event.find(params[:event_id])
  end
end
