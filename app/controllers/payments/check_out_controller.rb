class Payments::CheckOutController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!

  def event
    event = Event.find(event_params[:event_id])
    if event.is_paid == false
      customer = Payments::Customer.get(@resource)
      config = Payments::ItemsConfig.get_event
      items = [{id: config[:id], name: config[:name], description: config[:description], quantity: 1, unit_price: config[:unit_price],
                taxable: config[:taxable]}]
      tax = {:amount => ((config[:tax] * config[:unit_price]) / 100), :name => "tax", :description => "Tax venue top champ"}
      response = Payments::Charge.customer(customer.profile.customerProfileId, event_params[:card_id], event_params[:cvv],
                                           config[:unit_price], items, tax)
      if response.messages.resultCode == MessageTypeEnum::Ok
        if response.transactionResponse == nil && response.transactionResponse.messages == nil and response.transactionResponse.errors != nil
          return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
        end
      else
        if response.transactionResponse != nil && response.transactionResponse.errors != nil
          return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
        else
          return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
        end
      end

      event.create_payment_transaction!({:transaction_id => response.transactionResponse.transId})
      event.is_paid = true
      event.save!(:validate => false)
    end
    json_response_success("Successful", true)
  end


  private

  def event_params
    params.required(:event_id)
    params.required(:amount)
    params.required(:tax)
    params.required(:card_id)
    params.required(:cvv)
    params.permit(:event_id, :amount, :tax, :card_id, :cvv)
  end
end
