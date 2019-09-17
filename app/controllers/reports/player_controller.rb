class Reports::PlayerController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def receipts
    user = receipts_params[:user_id].present? ? User.find(receipts_params[:user_id]) : @resource
    transactions = Payments::PaymentTransaction.where(:event_id => receipts_params[:event_id]).where(:user_id => user.id)
    json_response_serializer_collection(transactions.all, PaymentTransactionSerializer)
  end

  private
  def receipts_params
    params.require('event_id')
    params.permit(:user_id, :event_id)
  end
end
