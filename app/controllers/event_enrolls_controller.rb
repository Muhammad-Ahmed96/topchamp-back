class EventEnrollsController < ApplicationController
  include Swagger::Blocks
  before_action :set_resource, only: [:create]
  before_action :authenticate_user!

  def create
    data = enroll_params.merge(:user_id => @resource.id, :status => :enroll)
    @event.enrolls.create!(data)
    json_response(@event)
  end


  private
  def enroll_params
    params.permit(:category_id, :event_bracket_age_id, :event_bracket_skill_id)
  end
  def set_resource
    @event = Event.find(params[:event_id])
  end
end
