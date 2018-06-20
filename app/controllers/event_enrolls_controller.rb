class EventEnrollsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:create, :index]
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]

  def index
    json_response_serializer_collection(@event.enrolls, EventEnrollSerializer)
  end
  swagger_path '/event/:id/enrolls' do
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
        data = enroll.merge(:user_id => @resource.id)
        my_enroll = @event.enrolls.where(:user_id => data[:user_id]).where(:category_id => data[:category_id]).first

        #Get status
        age = EventBracketAge.where(:event_id => @event.id).where(:id => data[:event_bracket_age_id]).first
        skill = EventBracketSkill.where(:event_id => @event.id).where(:id => data[:event_bracket_skill_id]).first

       # if my_enroll.nil?
          if age.present? && skill.present?
            if skill.event_bracket_age_id == age.id
              if skill.available_for_enroll
                data = data.merge(:status => :enroll)
              end
            elsif age.event_bracket_skill_id == skill.id
              if age.available_for_enroll
                data = data.merge(:status => :enroll)
              end
            end
          elsif age.present?
            if age.available_for_enroll
              data = data.merge(:status => :enroll)
            end
          elsif skill.present?
            if skill.available_for_enroll
              data = data.merge(:status => :enroll)
            end
          elsif my_enroll.nil?
            data = data.merge(:status => :wait_list)
          end
        #end

        if my_enroll.nil? and data[:status].nil?
          data = data.merge(:status => :wait_list)
        end

        #Save data
        if my_enroll.present?
          my_enroll.update! data
          #Player attendee
        else
          my_enroll = @event.enrolls.create!(data)
          my_enroll.attendee_type_ids = 7
        end

      }
    else
      @event.enrolls.create!(enroll_params)
    end
    json_response_serializer_collection(@event.enrolls, EventEnrollSerializer)
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

  def set_resource
    @event = Event.find(params[:event_id])
  end
end
