class Reports::DirectorController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def balance
    user = balance_params[:user_id].present? ? User.find(balance_params[:user_id]) : @resource
    my_events_ids = Event.only_creator(user.id).pluck(:id)
    #total of income
    transactions = Payments::PaymentTransaction.where(:event_id => my_events_ids).sum(:director_receipt)
    #Total of refunds
    refunds = Payments::RefundTransaction.where(:from_user_id => user.id).sum(:total)
    #total balance of director
    balance = number_with_precision(transactions - refunds, precision: 2).to_f
    json_response_data({:balance => balance})
  end

  private
  def balance_params
    params.permit(:user_id)
  end
end
