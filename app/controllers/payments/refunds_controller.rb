require 'action_view'
include ActionView::Helpers::NumberHelper
class Payments::RefundsController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!
  swagger_path '/payments/refunds/credit_card' do
    operation :post do
      key :summary, 'Refund credit card'
      key :description, 'Refund'
      key :operationId, 'refundCreditCard'
      key :produces, ['application/json',]
      key :tags, ['refunds']
      parameter do
        key :name, :amount
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :user_id
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :card_number
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      parameter do
        key :name, :expiration_date
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def credit_card
    card_number = credit_card_prams[:card_number]
    expiration_date = credit_card_prams[:expiration_date]
    unless credit_card_prams[:payment_transaction_id].nil?
      transaction = Payments::TransactionConnection.get_details(credit_card_prams[:payment_transaction_id])
      card_number = transaction.transaction.payment.creditCard.cardNumber.to_s
      expiration_date = transaction.transaction.payment.creditCard.expirationDate.to_s
    end

    unless credit_card_prams['amount'].to_f > 0
      return response_more_than
    end
    app_fee = 0.0
    user = @resource
    amount = number_with_precision(credit_card_prams[:amount], precision: 2).to_f
    response = Payments::Refund.credit_card(amount, card_number, expiration_date, credit_card_prams[:payment_transaction_id])
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
    payment = nil
    reference_id = nil
    unless credit_card_prams[:payment_transaction_id].nil?
      payment = Payments::PaymentTransaction.where(:payment_transaction_id => credit_card_prams[:payment_transaction_id]).first
    end
    unless payment.nil?
      total = payment.refund_total + amount
      payment.update!({:is_refund => true, :refund_total => total})
      reference_id = payment.id
    end

    authorize_fee =  ((Rails.configuration.authorize[:transaction_fee] * (amount - app_fee)) / 100) + Rails.configuration.authorize[:extra_charges]

    total_dir = amount + authorize_fee
    Payments::RefundTransaction.create!({:payment_transaction_id => response.transactionResponse.transId, :amount => amount, :type_refund => 'credit_card',
                                         :card_number => card_number, :expiration_date => expiration_date,:reference_id => reference_id,
                                         :from_user_id => user.id, :to_user_id => credit_card_prams[:user_id], :status => 'aproved',
                                         :app_fee => app_fee,:authorize_fee => authorize_fee,:total => total_dir, :event_id => credit_card_prams[:event_id]})



    json_response_data({:transaction => response.transactionResponse.transId})

  end

  swagger_path '/payments/refunds/bank_account' do
    operation :post do
      key :summary, 'Refund bank account'
      key :description, 'Refund'
      key :operationId, 'refundBankAccount'
      key :produces, ['application/json',]
      key :tags, ['refunds']
      parameter do
        key :name, :amount
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :user_id
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :routing_number
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      parameter do
        key :name, :account_number
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      parameter do
        key :name, :name_on_account
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      parameter do
        key :name, :bank_name
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :string
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end

  def bank_account
    unless bank_account_prams['amount'].numeric?
      return response_no_numeric
    end

    unless bank_account_prams['amount'].to_f > 0
      return response_more_than
    end
    user = @resource
    amount = number_with_precision(bank_account_prams[:amount], precision: 2).to_f
    app_fee = 0.0
    response = Payments::Refund.bank_account(amount, bank_account_prams[:routing_number], bank_account_prams[:account_number], bank_account_prams[:name_on_account],
                                             bank_account_prams[:bank_name])
    if response.messages.resultCode == MessageTypeEnum::Ok
      if response.transactionResponse.responseCode != "1" and response.transactionResponse.responseCode != "4"
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      end
    else
      if response.transactionResponse != nil && response.transactionResponse.errors != nil
        return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
      else
        return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
      end
    end
    authorize_fee =  ((Rails.configuration.authorize[:transaction_fee] * (amount - app_fee)) / 100) + Rails.configuration.authorize[:extra_charges]

    total_dir = amount + authorize_fee
    Payments::RefundTransaction.create!({:payment_transaction_id => response.transactionResponse.transId, :amount => amount, :type_refund => 'bank_account',
                                         :routing_number => bank_account_prams[:routing_number], :account_number => bank_account_prams[:account_number],
                                         :name_on_account => bank_account_prams[:name_on_account], :bank_name => bank_account_prams[:bank_name],
                                         :account_type => 'businessChecking', :e_check_type => 'CCD',:app_fee => app_fee,:authorize_fee => authorize_fee,:total => total_dir,
                                         :from_user_id => user.id, :to_user_id => bank_account_prams[:user_id],  :event_id => bank_account_prams[:event_id]})
    json_response_data({:transaction => response.transactionResponse.transId})
  end

  private

  def credit_card_prams
    params.require('amount')
    params.require('user_id')
    params.require('event_id')
    # params.require('card_number')
    #params.require('expiration_date')
    params.require('payment_transaction_id')
    params.permit('user_id', 'amount', 'card_number', 'expiration_date', 'payment_transaction_id', 'event_id')
  end

  def bank_account_prams
    params.require('amount')
    params.require('routing_number')
    params.require('account_number')
    params.require('name_on_account')
    params.require('bank_name')
    params.require('user_id')
    params.require('event_id')
    params.permit('user_id', 'check_number', 'amount', 'account_type', 'routing_number', 'account_number', 'name_on_account', 'bank_name', 'event_id')
  end

  def response_no_numeric
    return json_response_error(['Amount is not numeric'], 402)
  end

  def response_more_than
    return json_response_error(['Amount more than 0'], 402)
  end
end
