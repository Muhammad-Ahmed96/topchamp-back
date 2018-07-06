class EventEnrollsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:create, :index, :user_cancel, :change_attendees]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create, :user_cancel, :change_attendees]

  def index
    json_response_serializer_collection(@event.enrolls, EventEnrollSerializer)
  end

  swagger_path '/events/:id/enrolls' do
    operation :post do
      key :summary, 'Enroll to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventEnrollCreate'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :enrolls
        key :in, :body
        key :description, 'Enrolls'
        key :type, :array
        items do
          key :'$ref', :EventEnrollInput
        end
      end
      response 200 do
        key :name, :categories
        key :description, 'enrolls'
        schema do
          key :type, :array
          items do
            key :'$ref', :EventEnroll
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

  def create
    if enroll_collection_params.present?
      enroll_collection_params.each {|enroll|
        my_enroll = @event.add_enroll(@resource.id, enroll[:category_id], enroll[:event_bracket_age_id], enroll[:event_bracket_skill_id], [7])
        player = Player.where(:user_id => my_enroll.user_id).where(:event_id => my_enroll.event_id).first
        if player.nil?
          player = Player.create!(:user_id => my_enroll.user_id, :event_id => my_enroll.event_id, :status => :Active )
        end
        player.enroll_ids = [my_enroll.id]
      }
    end
    json_response_serializer_collection(@event.enrolls, EventEnrollSerializer)
  end
  swagger_path '/events/:id/enrolls/user_cancel' do
    operation :post do
      key :summary, 'Cancel registration to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventCancelRegistrationCreate'
      key :produces, ['application/json',]
      key :tags, ['events']
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
  def user_cancel
    authorize(@event)
    user_id = @resource.id
    @event.enrolls.where(:user_id => user_id).destroy_all
    json_response_success(t("success"), true)
  end
  swagger_path '/events/:id/enrolls/change_attendees' do
    operation :post do
      key :summary, 'Change attendees to event'
      key :description, 'Event Catalog'
      key :operationId, 'eventChangeAttendeesUser'
      key :produces, ['application/json',]
      key :tags, ['events']
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
  def change_attendees
    authorize(@event)
    user_id = @resource.id
    enroll = @event.enrolls.where(:user_id => user_id).first
    if enroll.present?
      enroll.attendee_type_ids = change_attendees_params[:attendee_type_ids]
    end
    json_response_success(t("success"), true)
  end


  private

  def enroll_params
    params.permit(:category_id, :event_bracket_age_id, :event_bracket_skill_id)
  end

  def enroll_collection_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_age_id, :event_bracket_skill_id)
      end
    end
  end

  def change_attendees_params
    params.permit(attendee_type_ids: [])
  end

  def set_resource
    @event = Event.find(params[:event_id])
  end

  def response_no_space_error
    json_response_error([t("insufficient_space")], 422)
  end
end
