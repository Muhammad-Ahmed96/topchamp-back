require 'action_view'
include ActionView::Helpers::NumberHelper
class Payments::RefundsController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!
  # todo refund logic
  def credit_card
    unless  credit_card_prams['amount'].numeric?
      return response_no_numeric
    end

    unless credit_card_prams['amount'].to_f > 0
      return response_more_than
    end

    amount = number_with_precision(credit_card_prams[:amount], precision: 2)
    response = Payments::Refund.credit_card(amount,credit_card_prams[:card_number], credit_card_prams[:expiration_date])
    if response.messages.resultCode == MessageTypeEnum::Ok
      #return json_response_error([response.transactionResponse.responseCode], 422, response.messages.messages[0].code)
      if response.transactionResponse.responseCode != "1"
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      end
    else
      if response.transactionResponse != nil && response.transactionResponse.errors != nil
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      else
        return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
      end
    end
    json_response_data({:transaction => response.transactionResponse.transId})

  end

  def bank_account
    unless  bank_account_prams['amount'].numeric?
      return response_no_numeric
    end

    unless bank_account_prams['amount'].to_f > 0
      return response_more_than
    end

    amount = number_with_precision(bank_account_prams[:amount], precision: 2)
    response = Payments::Refund.bank_account(amount,bank_account_prams[:routing_number], bank_account_prams[:account_number],  bank_account_prams[:name_on_account],
                                             bank_account_prams[:bank_name])
    if response.messages.resultCode == MessageTypeEnum::Ok
      #return json_response_error([response.transactionResponse.responseCode], 422, response.messages.messages[0].code)
      if response.transactionResponse.responseCode != "1"
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      end
    else
      if response.transactionResponse != nil && response.transactionResponse.errors != nil
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      else
        return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
      end
    end
    json_response_data({:transaction => response.transactionResponse.transId})
  end

  private
  def credit_card_prams
    params.require('amount')
    params.require('card_number')
    params.require('expiration_date')
    params.permit('amount', 'card_number', 'expiration_date')
  end

  def bank_account_prams
    params.require('amount')
    params.require('routing_number')
    params.require('account_number')
    params.require('name_on_account')
    params.require('bank_name')
    params.permit('check_number', 'amount', 'account_type', 'routing_number', 'account_number', 'name_on_account', 'bank_name')
  end

  def response_no_numeric
    return json_response_error(['Amount is not numeric'], 402)
  end

  def response_more_than
    return json_response_error(['Amount more than 0'], 402)
  end
end
