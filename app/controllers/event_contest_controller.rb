class EventContestController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:destroy]

  def destroy
    reason = @contest.validate_to_delete
    unless reason.nil?
      return response_impossible_eliminate(reason)
    end
    @contest.destroy
    json_response_success(t("deleted_success", model: EventContest.model_name.human), true)
  end

  private

  def set_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:id]).first!
  end

  def response_impossible_eliminate(message)
    return json_response_error([message])
  end
end
