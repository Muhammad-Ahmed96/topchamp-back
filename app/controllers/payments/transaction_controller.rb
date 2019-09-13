class Payments::TransactionController < ApplicationController

  def show
    transaction = Payments::PaymentTransaction.find(show_params[:id])
    event = Event.find(transaction.event_id);
    is_paid_fee = event.is_paid_fee(transaction.user_id)
    brackets = transaction.details.select('discount', 'tax', 'amount', 'id', 'total AS cost').where(type_payment: 'bracket').all
    event_enroll = transaction.details.select('discount', 'tax', 'amount', 'id', 'total AS cost').where(type_payment: 'event_enroll').first

    brackets.each do |item|
      item.tax =  (item.discount - item.cost).round(2)
    end

    unless event_enroll.nil?
      event_enroll.tax = (event_enroll.discount - event_enroll.cost).round(2)
    end
    json_response_data({:tax => transaction.tax, :total => transaction.amount, :event_enroll => event_enroll,
                        discount: transaction.discount, cost: transaction.total, :is_paid_fee => is_paid_fee, :brackets => brackets})
  end

  private
  def show_params
    params.required('id')
    params.permit('id')
  end
end
