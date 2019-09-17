class Reports::PlayerController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def receipts
    user = receipts_params[:user_id].present? ? User.find(receipts_params[:user_id]) : @resource
    transactions = Payments::PaymentTransaction.where(:event_id => receipts_params[:event_id]).where(:user_id => user.id)
    transactions.each do |transaction|
      brackets_ids = []
      details_ids = []
      details = transaction.details.where.not(:event_bracket_id => nil).all
      details.each do |detail|
        details_ids.push(detail.event_bracket_id)
        unless detail.bracket.nil?
          if detail.bracket.event_contest_category_bracket_id.present?
            brackets_ids.push(detail.bracket.event_contest_category_bracket_id)
          else
            brackets_ids.push(detail.bracket.parent_bracket.event_contest_category_bracket_id)
            details_ids.push(detail.bracket.event_contest_category_bracket_detail_id)
          end
        end
      end
      contest = EventContest.joins(:categories => [:brackets]).merge(EventContestCategoryBracket.where(:id => brackets_ids))
                    .distinct.all
      contest.each do |item|
        item.filter_categories = EventContestCategory.joins(:brackets).merge(EventContestCategoryBracket.where(:id => brackets_ids)).all
        item.filter_categories.each do |category|
          category.filter_brackets = category.brackets.where(:id => brackets_ids).all
          category.filter_brackets.each do |bracket|
            bracket.filter_details = bracket.details.where(:id => details_ids).all
            bracket.filter_details.each do |detail|
              detail.receipt =  transaction.details.where(:contest_id => item.id).where(:event_bracket_id => detail.id).first
              detail.filter_brackets = detail.brackets.where(:id => details_ids).all
              detail.filter_brackets.each do |child|
                child.receipt =  transaction.details.where(:contest_id => item.id).where(:event_bracket_id => child.id).first
              end
            end
          end
        end
      end
      transaction.contests_payments = contest
      transaction.event_payments= transaction.details.where(:type_payment => 'event_enroll').all
    end
    json_response_serializer_collection(transactions, PaymentTransactionContestSerializer)
  end

  private

  def receipts_params
    params.require('event_id')
    params.permit(:user_id, :event_id)
  end
end
