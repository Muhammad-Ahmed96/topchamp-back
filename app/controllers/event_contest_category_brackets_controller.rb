class EventContestCategoryBracketsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_resource, only: [:destroy]
  before_action :set_category_resource, only: [:available]
  around_action :transactions_filter, only: [:destroy]

  def destroy
    reason = @bracket.validate_to_delete
    unless reason.nil? or destroy_params[:force_delete].to_s == "1"
      return response_impossible_eliminate(reason)
    end
    #Send to refund contest payments of players
    @bracket.players.each do |player|
      player.payment_transactions.where(:contest_id => @bracket.category.event_contest_id).where(:is_refund => false).update_all({:for_refund => true})
    end
    PlayerBracket.where(:event_bracket_id => @bracket.brackets_ids).destroy_all
    @bracket.destroy
    json_response_success(t("deleted_success", model: EventContestCategory.model_name.human), true)
  end

  def destroy_detail
    @bracket_detail = EventContestCategoryBracketDetail.where(:id => params[:id]).first!
    reason = @bracket_detail.validate_to_delete
    unless reason.nil? or destroy_params[:force_delete].to_s == "1"
      return response_impossible_eliminate(reason)
    end
    #Send to refund contest payments of players
    @bracket_detail.players.each do |player|
      player.payment_transactions.where(:contest_id => @bracket_detail.contest_id).where(:is_refund => false).update_all({:for_refund => true})
    end
    PlayerBracket.where(:event_bracket_id => @bracket_detail.brackets_ids).destroy_all
    @bracket_detail.destroy
    json_response_success(t("deleted_success", model: EventContestCategory.model_name.human), true)
  end


  def available
    used_ids = Tournament.where(:event_id => @event.id).where(:category_id => @category.category_id).where(:contest_id => @contest.id).pluck(:event_bracket_id)
    brackets = EventContestCategoryBracketDetail.where(:event_contest_category_bracket_id => @category.id)
                   .where.not(:id => used_ids)
    json_response_serializer_collection(brackets, EventContestCategoryBracketDetailSerializer)
  end

  private

  def set_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:event_contest_id]).first!
    @category = @contest.categories.where(:category_id => params[:event_contest_category_id] ).first!
    @bracket = @category.brackets.where(:bracket_type => params[:id] ).first!
  end

  def set_category_resource
    @event = Event.find(params[:event_id])
    @contest = @event.contests.where(:id => params[:event_contest_id]).first!
    @category = @contest.categories.where(:category_id => params[:event_contest_category_id] ).first!
  end

  def response_impossible_eliminate(message)
    return json_response_error([message])
  end

  def destroy_params
    params.permit(:force_delete)
  end
end
