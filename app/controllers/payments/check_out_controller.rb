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
        key :name, :code
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
    is_test = false #change to false for checkout event on authorize.net
    event = Event.find(event_params[:event_id])
    if event.is_paid == false
      director = event.director
      customer = Payments::Customer.get(@resource)
      config = Payments::ItemsConfig.get_event
      amount = 0
      total_discount = 0
      total_fee = 0
      fees = EventFee.first
      if fees.present? and fees.base_fee > 0 and is_test == false
        personalized_discount = EventPersonalizedDiscount.where(:code => event_params[:code]).where(:email => director.email).first
        if event_params[:code].present? and personalized_discount.nil?
          return response_invalid
        elsif event_params[:code].present? and personalized_discount.usage > 0
          return response_usage
        end
        if fees.present?
          amount = fees.base_fee
        end
        if personalized_discount.present?
          if personalized_discount.is_discount_percent
            total_discount =  ((personalized_discount.discount * amount) / 100)
            amount = amount - total_discount
          else
            total_discount = personalized_discount.discount
            amount = amount - total_discount
          end
          personalized_discount.usage = general_discount.usage + 1
          personalized_discount.save!(:validate => false)
        end

        if fees.present?
          if fees.is_transaction_fee_percent
            total_fee =  ((fees.transaction_fee * amount) / 100)
            amount = amount + total_fee
          else
            total_fee = fees.transaction_fee
            amount = amount + total_fee
          end
        end
        #only for test
        #amount = 1
        items = [{id: "#{config[:id]}-#{event.id}", name: config[:name], description: config[:description], quantity: 1, unit_price: amount,
                  taxable: config[:taxable]}]
        tax = {:amount => ((config[:tax] * amount) / 100), :name => "tax", :description => "Tax venue top champ"}
        #only for test
        #tax[:amount] = 0
        #
        amount = amount + tax[:amount]
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
          if response.transactionResponse.cvvResultCode != '' and response.transactionResponse.cvvResultCode != "M"
            return json_response_error([Payments::Charge.get_message(response.transactionResponse.cvvResultCode)], 422, response.messages.messages[0].code)
          end
        else
          if response.transactionResponse != nil && response.transactionResponse.errors != nil
            return json_response_error([response.transactionResponse.errors.errors[0].errorText], 422, response.transactionResponse.errors.errors[0].errorCode)
          else
            return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
          end
        end
      else
        tax = {:amount => ((config[:tax] * amount) / 100), :name => "tax", :description => "Tax venue top champ"}
        response = JSON.parse({transactionResponse: {transId: '000'}}.to_json, object_class: OpenStruct)
      end

      authorize_fee =  ((Rails.configuration.authorize[:transaction_fee] * amount) / 100) + Rails.configuration.authorize[:extra_charges]
      account = amount - authorize_fee
      app_fee = total_fee
      director_receipt = amount - (authorize_fee + app_fee)
      paymentTransaction = event.create_payment_transaction!(:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id,
                                                               :amount => amount, :tax => number_with_precision(tax[:amount], precision: 2), :description => "EventPayment",
                                                               :event_id => event.id, :discount => total_discount, :authorize_fee => authorize_fee, :app_fee => app_fee,
                                                               :director_receipt => director_receipt, :account => account)

      paymentTransaction.details.create!({:amount => amount, :tax => number_with_precision(tax[:amount], precision: 2),
                                          :event_id => event.id, :type_payment => "event_payment", :discount => total_discount})
      event.is_paid = true
      event.status = :Active
      if personalized_discount
        event.personalized_discount_code_id = personalized_discount.id
        event.personalized_discount = personalized_discount.discount
      end
      event.save!(:validate => false)
      event.public_url
      json_response_data([:transaction => response.transactionResponse.transId], :ok)
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
        key :required, true
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
    #only for test
    # @resource = User.find(params[:user_id])
    event = Event.find(subscribe_params[:event_id])
    brackets = event.available_brackets(player_brackets_params)
    if brackets.length <= 0
      return response_no_enroll_error
    end
    config = Payments::ItemsConfig.get_bracket
    prices = event.calculate_prices(brackets, @resource, subscribe_params[:discount_code])
    items = []
    #only for test
    #enroll_fee = 1
    #bracket_fee = 1
    #first item event fee
    item = {id: "Fee-#{event.id}", name: "Enroll fee", description: "Enroll fee", quantity: 1, unit_price: prices.enroll_amount,
            taxable: true}
    items << item

    brackets.each do |bracket|
      if bracket[:enroll_status] == :enroll
        item = {id: "#{config[:id]}-#{bracket[:event_bracket_id]}", name: "Bracket-#{bracket[:event_bracket_id]}",
                description: "Subscribe to Bracket-#{bracket[:event_bracket_id]}", quantity: 1, unit_price: prices.bracket_amount,
                taxable: true}
        items << item
      end
    end
    # no payment if items is empty
    # Comment on test
    # Only for test
    #amount = 1
    #tax[:amount] = 1
    amount =  prices.amount <= 0 ? 0 : number_with_precision(prices.amount, precision: 2)
    if items.length > 0 and amount > 0
      customer = Payments::Customer.get(@resource)
      response = Payments::Charge.customer(customer.profile.customerProfileId, event_params[:card_id], event_params[:cvv],
                                           amount, items, prices.tax)
      if response.messages.resultCode == MessageTypeEnum::Ok
        #return json_response_error([response.transactionResponse.responseCode], 422, response.messages.messages[0].code)
        if response.transactionResponse.responseCode != "1"
          case response.transactionResponse.responseCode
          when "2"
            return json_response_error([t("payments.declined")], 422, response.transactionResponse.responseCode)
          end
        end
        if response.transactionResponse.cvvResultCode != '' and response.transactionResponse.cvvResultCode != "M"
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
    # end Comment on test
    #only for test
     response =  JSON.parse({transactionResponse: {transId: '000'}}.to_json, object_class: OpenStruct)
    #save bracket on player
    player = Player.where(user_id: @resource.id).where(event_id: event.id).first_or_create!
    player.sync_brackets!(brackets, true)

    fees = EventFee.first
    app_fee = 0.0
    amount = amount.to_f
    if fees.present?
      if fees.is_transaction_fee_percent
        app_fee =  ((fees.transaction_fee * amount) / 100)
      else
        app_fee = fees.transaction_fee
      end
    end
    authorize_fee =  amount <=0 ? 0 : ((Rails.configuration.authorize[:transaction_fee] * amount) / 100) + Rails.configuration.authorize[:extra_charges]
    account = amount - authorize_fee
    director_receipt = amount - (authorize_fee + app_fee)
    paymentTransaction = player.payment_transactions.create!(:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id,
                                                             :amount => amount, :tax => number_with_precision(prices.tax_total, precision: 2), :description => "TransactionForSubscribe",
                                                             :event_id => player.event_id, :discount => prices.discounts_total, :authorize_fee => authorize_fee, :app_fee => app_fee,
                                                             :director_receipt => director_receipt, :account => account,
                                                             :total => prices.sub_total)
    bracket_amount_one = brackets.length <= 0 ? 0 : prices.bracket_amount / brackets.length
    bracket_discount_one = brackets.length <= 0 ? 0 : prices.bracket_discount / brackets.length
    brackets.each do |item|
      paymentTransaction.details.create!({:amount => bracket_amount_one, :tax => number_with_precision(prices.tax_for_bracket, precision: 2),
                                  :event_bracket_id => item[:event_bracket_id], :category_id => item[:category_id],
                                  :event_id => player.event_id, :type_payment => "bracket", :contest_id => item[:contest_id],
                                          :discount => bracket_discount_one, :total => prices.bracket_fee})
    end
    paymentTransaction.details.create!({:amount => prices.enroll_amount, :tax => number_with_precision(prices.tax_for_registration, precision: 2),
                                :event_id => player.event_id, :type_payment => "event_enroll", :attendee_type_id => AttendeeType.player_id,
                                       :discount => prices.enroll_discount, :total => prices.enroll_fee})

    player.brackets.where(:enroll_status => :enroll).where(:payment_transaction_id => nil)
        .where(:event_bracket_id => brackets.pluck(:event_bracket_id))
        .update(:payment_transaction_id => response.transactionResponse.transId)
    my_brackets =  player.brackets_enroll.where(:event_bracket_id => brackets.pluck(:event_bracket_id)).all
    my_brackets.each do |bracket|
      category_type = ""
      if [bracket.category_id.to_i].included_in? Category.doubles_categories_exact
        category_type = "partner_double"
      elsif [bracket.category_id.to_i].included_in? Category.mixed_categories
        category_type = "partner_mixed"
      end
      invitation = Invitation.where(:event_id => player.event_id).where(:user_id => player.user_id).where(:status => :accepted).where(:invitation_type => category_type)
                       .joins(:brackets).merge(InvitationBracket.where(:event_bracket_id => bracket.event_bracket_id)).first
      if invitation.present?
        result = Player.validate_partner(player.user_id, invitation.sender_id,  bracket.event_bracket_id, bracket.category_id)
        if result == true
          bracket.update({:is_root => false, :partner_id => invitation.sender_id})
        end
      end
    end
    player.set_teams my_brackets
    json_response_data({:transaction => response.transactionResponse.transId})
  end

  swagger_path '/payments/check_out/schedule' do
    operation :post do
      key :summary, 'Check out schedule'
      key :description, 'Check out schedule'
      key :operationId, 'paymentsSchedule'
      key :produces, ['application/json',]
      key :tags, ['schedule check out']
      parameter do
        key :name, :event_schedule_id
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

  def schedule
    schedule = EventSchedule.find(schedule_params[:event_schedule_id])
    event = schedule.event
    user = @resource
    tax_for_registration = 0
    save_transaction = false
    amount = schedule.cost.present? ? schedule.cost : 0
    if amount > 0
      save_transaction = true
      tax = {:amount => tax_for_registration, :name => "tax", :description => "Tax event schedule"}

      if event.tax.present?
        if event.tax.is_percent
          tax = {:amount => ((event.tax.tax * amount) / 100), :name => "tax", :description => "Tax to shedule"}
        else
          tax = {:amount => event.tax.tax, :name => "tax", :description => "Tax to shedule"}
        end

      end
      #for test
      amount = 1
      tax[:amount] = 0
      items = [{id: "Schedule-#{schedule.id}", name: "Enroll schedule", description: "Enroll schedule", quantity: 1, unit_price: amount,
                taxable: true}]
      customer = Payments::Customer.get(user)
      amount = amount + tax[:amount]
      response = Payments::Charge.customer(customer.profile.customerProfileId, schedule_params[:card_id], schedule_params[:cvv],
                                           amount, items, tax)
      if response.messages.resultCode == MessageTypeEnum::Ok
        if response.transactionResponse.responseCode != "1"
          case response.transactionResponse.responseCode
          when "2"
            return json_response_error([t("payments.declined")], 422, response.transactionResponse.responseCode)
          end
        end
        if response.transactionResponse.cvvResultCode != '' and response.transactionResponse.cvvResultCode != "M"
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

    fees = EventFee.first
    amount = amount.to_f
    app_fee = 0.0
    if fees.present?
      if fees.is_transaction_fee_percent
        app_fee =  ((fees.transaction_fee * amount) / 100)
      else
        app_fee = fees.transaction_fee
      end
    end
    authorize_fee =  ((Rails.configuration.authorize[:transaction_fee] * amount) / 100) + Rails.configuration.authorize[:extra_charges]
    account = amount - authorize_fee
    director_receipt = amount - (authorize_fee + app_fee)
    player = Player.where(user_id: user.id).where(event_id: schedule.event_id).first
    if player.present?
      if save_transaction
        paymentTransaction = player.payment_transactions.create!(:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id,
                                                                :amount => amount, :tax => number_with_precision(tax[:amount], precision: 2), :description => "SchedulePayment",
                                                                :event_id => event.id, :discount => 0, :authorize_fee => authorize_fee, :app_fee => app_fee,
                                                                :director_receipt => director_receipt, :account => account)

        paymentTransaction.details.create!({:amount => amount, :tax => number_with_precision(tax[:amount], precision: 2),:event_schedule_id => schedule.id,
                                            :event_id => event.id, :type_payment => "shedule", :discount => 0})
      end
      schedules_ids = player.schedule_ids + [schedule.id]
      player.schedule_ids = schedules_ids
    else
      participant = Participant.where(:user_id => user.id).where(:event_id => schedule.event_id).first_or_create!
      if save_transaction

        paymentTransaction = participant.payment_transactions.create!(:payment_transaction_id => response.transactionResponse.transId, :user_id => @resource.id,
                                                                 :amount => amount, :tax => number_with_precision(tax[:amount], precision: 2), :description => "SchedulePayment",
                                                                 :event_id => event.id, :discount => total_discount, :authorize_fee => authorize_fee, :app_fee => app_fee,
                                                                 :director_receipt => director_receipt, :account => account)

        paymentTransaction.details.create!({:amount => amount, :tax => number_with_precision(tax[:amount], precision: 2),:event_schedule_id => schedule.id,
                                            :event_id => event.id, :type_payment => "shedule", :discount => total_discount})
      end
      schedules_ids = participant.schedule_ids + [schedule.id]
      participant.schedule_ids = schedules_ids
    end
    if save_transaction
      json_response_data({:transaction => response.transactionResponse.transId})
    else
      json_response_success("You are now enrolled!", true)
    end

  end

  private

  def event_params
    params.required(:event_id)
    #params.required(:amount)
    #params.required(:tax)
    params.required(:card_id)
    params.required(:cvv)
    params.permit(:event_id, :amount, :tax, :card_id, :cvv, :code)
  end

  def subscribe_params
    params.required(:event_id)
    params.required(:card_id)
    params.required(:cvv)
    params.required(:enrolls)
    params.permit(:event_id, :contest_id, :amount, :tax, :card_id, :cvv, :discount_code, enrolls: [:category_id, :event_bracket_id, :contest_id])
  end

  def schedule_params
    params.required(:event_schedule_id)
    params.required(:card_id)
    params.required(:cvv)
    params.permit(:event_schedule_id, :amount, :tax, :card_id, :cvv)
  end

  def player_brackets_params
    unless params[:enrolls].nil? and !params[:enrolls].kind_of?(Array)
      params[:enrolls].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:category_id, :contest_id, :event_bracket_id)
      end
    end
  end


  def response_no_space_error
    json_response_error([t("insufficient_space")], 422)
  end

  def response_no_enroll_error
    json_response_error([t("not_brackets_to_enrroll")], 422)
  end


  def response_invalid
    json_response_error(["Invalid discount code."], 422)
  end

  def response_usage
    json_response_error(["Your discount code has reached its usage limit."], 422)
  end
end
