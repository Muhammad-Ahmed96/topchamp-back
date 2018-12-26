class EventContestController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:destroy, :change_type]
  before_action :set_event_resource, only: [:index]
  around_action :transactions_filter, only: [:destroy]

  def destroy
    reason = @contest.validate_to_delete
    unless reason.nil? or destroy_params[:force_delete].to_s == "1"
      return response_impossible_eliminate(reason)
    end
    brackets_ids = @contest.brackets_ids
    #Send to refund contest payments of players
    @contest.players.each do |player|
      player.payment_transactions.where(:contest_id => @contest.id).where(:is_refund => false).update_all({:for_refund => true})
    end
    PlayerBracket.where(:event_bracket_id => brackets_ids).destroy_all
    @contest.destroy
    json_response_success(t("deleted_success", model: EventContest.model_name.human), true)
  end

  def change_type
    reason = @contest.validate_to_delete
    unless reason.nil? or destroy_params[:force_delete].to_s == "1"
      return response_impossible_eliminate(reason)
    end
    brackets_ids = @contest.brackets_ids
    #Send to refund contest payments of players
    @contest.players.each do |player|
      player.payment_transactions.where(:contest_id => @contest.id).where(:is_refund => false).update_all({:for_refund => true})
    end
   PlayerBracket.where(:event_bracket_id => brackets_ids).destroy_all
   @contest.categories.destroy_all
    json_response_success(t("deleted_success", model: EventContest.model_name.human), true)
  end


  def index
    json_response_serializer_collection(@event.contests, EventContestSerializer)
  end

  private

  def set_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:id]).first!
  end

  def set_event_resource
    @event = Event.find(params[:event_id])
  end

  def response_impossible_eliminate(message)
    return json_response_error([message])
  end

  def destroy_params
    params.permit(:force_delete)
  end
end
