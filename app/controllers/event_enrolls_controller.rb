class EventEnrollsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:create, :index, :user_cancel, :change_attendees, :unsubscribe]
  around_action :transactions_filter, only: [:create, :user_cancel, :change_attendees, :unsubscribe]

  def index
    json_response_serializer_collection(@event.players, PlayerSerializer)
  end

=begin
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
          key :'$ref', :PlayerBracketInput
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

=begin
  def create
    brackets = @event.available_brackets(player_brackets_params)
    if brackets.length > 0
      player = Player.where(user_id: @resource.id).where(event_id: @event.id).first_or_create!
      player.sync_brackets! brackets
      return json_response_serializer(player, PlayerSerializer)
    else
      return response_no_enroll_error
    end

  end
=end

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
    @event.players.where(:user_id => @resource.id).each do |player|
      player.inactivate
      player.unsubscribe_event
    end
    @event.participants.where(:user_id => @resource.id).destroy_all
    json_response_success(t("success"), true)
  end

  swagger_path '/events/:id/enrolls/unsubscribe' do
    operation :post do
      key :summary, 'Cancel unsubscribe to bracket'
      key :description, 'Event Catalog'
      key :operationId, 'eventUnsubscribeEnroll'
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
        key :name, :category_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :event_bracket_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
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
  def unsubscribe
    @event.players.where(:user_id => @resource.id).each do |player|
      #player.inactivate
      player.unsubscribe(unsubscribe_params[:category_id], unsubscribe_params[:event_bracket_id])
    end
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
    participant = @event.participants.where(:user_id => @resource.id).first!
    participant.attendee_type_ids = change_attendees_params[:attendee_type_ids]
    json_response_success(t("success"), true)
  end


  private

  def enroll_params
    params.permit(:category_id, :event_bracket_id,)
  end

  def player_brackets_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_id)
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

  def response_no_enroll_error
    json_response_error([t("not_brackets_to_enrroll")], 422)
  end

  def unsubscribe_params
    params.required(:category_id)
    params.required(:event_bracket_id)
    params.permit(:category_id, :event_bracket_id,)
  end
end
