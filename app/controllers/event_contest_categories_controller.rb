class EventContestCategoriesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:destroy]
  before_action :set_contest_resource, only: [:index]
  around_action :transactions_filter, only: [:destroy]

  def destroy
    reason = @category.validate_to_delete
    unless reason.nil? or destroy_params[:force_delete].to_s == "1"
      return response_impossible_eliminate(reason)
    end
    #Send to refund contest payments of players
    @category.players.each do |player|
      player.payment_transactions.where(:contest_id => @category.event_contest_id).where(:is_refund => false).update_all({:for_refund => true})
    end
    PlayerBracket.where(:event_bracket_id => @category.brackets_ids).destroy_all
    @category.destroy
    json_response_success(t("deleted_success", model: EventContestCategory.model_name.human), true)
  end

  def index
    json_response_serializer_collection(@contest.categories, EventContestCategorySingleSerializer)
  end

  private

  def set_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:event_contest_id]).first!
    @category = @contest.categories.where(:category_id => params[:id] ).first!
  end

  def set_contest_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:event_contest_id]).first!
  end

  def response_impossible_eliminate(message)
    return json_response_error([message])
  end

  def destroy_params
    params.permit(:force_delete)
  end
end
