require 'action_view'
include ActionView::Helpers::NumberHelper
class Payments::RefundsController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!
  # todo refund logic
  def credit_card
    unless  credit_card_prams['amount'].is_a? Numeric
      return response_no_numeric
    end

    unless credit_card_prams['amount'].to_f > 0
      return response_more_than
    end

  end

  def bank_account
    unless  credit_card_prams['amount'].is_a? Numeric
      return response_no_numeric
    end

    unless credit_card_prams['amount'].to_f > 0
      return response_more_than
    end
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
    params.require('account_type')
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
