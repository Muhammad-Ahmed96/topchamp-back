require 'action_view'
include ActionView::Helpers::NumberHelper
class Payments::CheckOutController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:subscribe]
  swagger_path '/payments/check_out/event' do
    operation :post do
      key :summary, 'Check out event'
      key :description, 'Check out'
      key :operationId, 'paymentsCheckOutEvent'
      key :produces, ['application/json',]
      key :tags, ['payments check out']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :amount
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :float
      end
      parameter do
        key :name, :tax
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :float
      end
      parameter do
        key :name, :card_id
        key :description, 'customerPaymentProfileId of card'
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :cvv
        key :in, :body
        key :required, true
        key :type, :string
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

  def event
    event = Event.find(event_params[:event_id])
    if event.is_paid == false
      customer = Payments::Customer.get(@resource)
      config = Payments::ItemsConfig.get_event
      items = [{id: "#{config[:id]}-#{event.id}", name: config[:name], description: config[:description], quantity: 1, unit_price: config[:unit_price],
                taxable: config[:taxable]}]
      tax = {:amount => ((config[:tax] * config[:unit_price]) / 100), :name => "tax", :description => "Tax venue top champ"}
      response = Payments::Charge.customer(customer.profile.customerProfileId, event_params[:card_id], event_params[:cvv],
                                           config[:unit_price], items, tax)
      if response.messages.resultCode == MessageTypeEnum::Ok
        #return json_response_error([response.transactionResponse.responseCode], 422, response.messages.messages[0].code)
        if response.transactionResponse.responseCode != "1"
          case response.transactionResponse.responseCode
          when "2"
            return json_response_error([t("payments.declined")], 422, response.transactionResponse.responseCode)
          end
        end
        if response.transactionResponse.cvvResultCode != "M"
          return json_response_error([Payments::Charge.get_message(response.transactionResponse.cvvResultCode)], 422, response.messages.messages[0].code)
        end
      else
        if response.transactionResponse != nil && response.transactionResponse.errors != nil
          return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
        else
          return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
        end
      end

      event.create_payment_transaction!({:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id, :amount => config[:unit_price], :tax => tax[:amount],
                                         :description => "Event payment"})
      event.is_paid = true
      event.status = :Active
      event.save!(:validate => false)
      event.public_url
      json_response_data([:transaction => response.transactionResponse.transId ], :ok)
    else
      json_response_error(["event is already paid"], 401)
    end

  end
  swagger_path '/payments/check_out/subscribe' do
    operation :post do
      key :summary, 'Check out brackets'
      key :description, 'Check out brackets'
      key :operationId, 'paymentsCheckOutBrackets'
      key :produces, ['application/json',]
      key :tags, ['payments check out']
      parameter do
        key :name, :event_id
        key :in, :body
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, :card_id
        key :description, 'customerPaymentProfileId of card'
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :cvv
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :discount_code
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :enrolls
        key :in, :body
        key :description, 'Enrolls'
        key :type, :array
        items do
          key :'$ref', :PlayerBracketInput
        end
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
  def subscribe
    event = Event.find(subscribe_params[:event_id])
    brackets = event.available_brackets(player_brackets_params)

    if brackets.length <= 0
      return response_no_enroll_error
    end
    config = Payments::ItemsConfig.get_bracket
    items = []
    amount = 0
    enroll_fee = event.registration_fee
    bracket_fee = event.payment_method.present? ? event.payment_method.bracket_fee : 0
    #aply discounts
    #event_discount = event.get_discount
    personalized_discount = event.discount_personalizeds.where(:code => subscribe_params[:discount_code]).where(:email => @resource.email).first
    general_discount = event.discount_generals.where(:code => subscribe_params[:discount_code]).first

    #enroll_fee = enroll_fee - ((event_discount * enroll_fee) / 100)
    #todo discount
    #bracket_fee = bracket_fee - ((event_discount * bracket_fee) / 100)

    if personalized_discount.present?
      enroll_fee =  enroll_fee - ((personalized_discount.discount * enroll_fee) / 100)
      #bracket_fee = bracket_fee - ((personalized_discount.discount * bracket_fee) / 100)
    elsif general_discount.present? and general_discount.limit < general_discount.applied
      enroll_fee = enroll_fee - ((general_discount.discount * enroll_fee) / 100)
      #bracket_fee = bracket_fee - ((general_discount.discount * bracket_fee) / 100)
      general_discount.applied = general_discount.applied + 1
      general_discount.save!(:validate => false)
    end
    #first item event fee
    item = {id: "Fee-#{event.id}", name: "Enroll fee", description: "Enroll fee", quantity: 1, unit_price: enroll_fee,
            taxable: true}
    items << item
    brackets.each do |bracket|
      if bracket[:enroll_status] == :enroll
        item = {id: "#{config[:id]}-#{bracket[:event_bracket_id]}", name: "Bracket-#{bracket[:event_bracket_id]}", description: "Subscribe to Bracket-#{bracket[:event_bracket_id]}", quantity: 1, unit_price: bracket_fee,
                taxable: true}
        amount += bracket_fee
        items << item
      end
    end
    amount += enroll_fee
    customer = Payments::Customer.get(@resource)
    #set tax of event
    tax = nil
    #todo review process
    if event.tax.present?
      if event.tax.is_percent
        tax = {:amount => ((event.tax.tax * amount) / 100), :name => "tax", :description => "Tax to enroll"}
      else
        tax = {:amount => event.tax.tax, :name => "tax", :description => "Tax to enroll"}
      end

    end

    # no payment if items is empty
    if items.length > 0
      amount = number_with_precision(amount, precision: 2)
      response = Payments::Charge.customer(customer.profile.customerProfileId, event_params[:card_id], event_params[:cvv],
                                           amount, items, tax)
      if response.messages.resultCode == MessageTypeEnum::Ok
        #return json_response_error([response.transactionResponse.responseCode], 422, response.messages.messages[0].code)
        if response.transactionResponse.responseCode != "1"
          case response.transactionResponse.responseCode
          when "2"
            return json_response_error([t("payments.declined")], 422, response.transactionResponse.responseCode)
          end
        end
        if response.transactionResponse.cvvResultCode != "M"
          return json_response_error([Payments::Charge.get_message(response.transactionResponse.cvvResultCode)], 422, response.messages.messages[0].code)
        end
      else
        if response.transactionResponse != nil && response.transactionResponse.errors != nil
          return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
        else
          return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
        end
      end
    end
    #save bracket on player
    player = Player.where(user_id: @resource.id).where(event_id: event.id).first_or_create!
    player.sync_brackets! brackets
    player.payment_transactions.create!({:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id, :amount => amount, :tax => number_with_precision(tax.present? ? tax[:amount] : 0, precision: 2),
                                         :description => "Bracket subscribe payment"})
    player.brackets.where(:enroll_status => :enroll).where(:payment_transaction_id => nil).update(:payment_transaction_id =>  response.transactionResponse.transId)
    json_response_data({:transaction => response.transactionResponse.transId})
  end


  private

  def event_params
    params.required(:event_id)
    #params.required(:amount)
    #params.required(:tax)
    params.required(:card_id)
    params.required(:cvv)
    params.permit(:event_id, :amount, :tax, :card_id, :cvv)
  end

  def subscribe_params
    params.required(:event_id)
    params.required(:card_id)
    params.required(:cvv)
    params.required(:enrolls)
    params.permit(:event_id, :amount, :tax, :card_id, :cvv, :discount_code, enrolls: [:category_id, :event_bracket_id])
  end

  def player_brackets_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :event_bracket_id)
      end
    end
  end


  def response_no_space_error
    json_response_error([t("insufficient_space")], 422)
  end

  def response_no_enroll_error
    json_response_error([t("not_brackets_to_enrroll")], 422)
  end
end
