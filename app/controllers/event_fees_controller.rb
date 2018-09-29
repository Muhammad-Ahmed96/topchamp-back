class EventFeesController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  swagger_path '/event_fees' do
    operation :post do
      key :summary, 'Save discount codes and event fee'
      key :description, 'User Catalog'
      key :operationId, 'userEventFeeSave'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :user_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :base_fee
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :float
      end
      parameter do
        key :name, :transaction_fee
        key :in, :body
        key :required, true
        key :type, :number
        key :format, :float
      end

      parameter do
        key :name, :discounts
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :'$ref', :UserEventPersonalizedDiscountInput
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
  def create
    if fees_params.present?
      event_fee = EventFee.first
      if event_fee.present?
        event_fee.update!(fees_params)
      else
        EventFee.create!(fees_params)
      end
    end
    if discounts_params.present?
      @resource.sync_personalized_discount(discounts_params)
    end
    json_response_success(t("created_success", model: UserEventFee.model_name.human), true)
  end

  swagger_path '/event_fees' do
    operation :get do
      key :summary, 'show event fee user'
      key :description, 'User Catalog'
      key :operationId, 'userEventFeeIndexave'
      key :produces, ['application/json',]
      key :tags, ['users']
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
  def index
    json_response({event_fee: EventFee.first, personalized_discount: EventPersonalizedDiscount.all})
  end
  swagger_path '/event_fees/calculate' do
    operation :get do
      key :summary, 'calculate event fee user'
      key :description, 'User Catalog'
      key :operationId, 'userEventFeeCalculate'
      key :produces, ['application/json',]
      key :tags, ['users']
      parameter do
        key :name, :code
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
  def calculate
    base_fee = 0
    transaction_fee = 0
    amount = 0
    fees = EventFee.first
    personalized_discount = EventPersonalizedDiscount.where(:code => calculate_params[:code]).where(:email => @resource.email).first
    if fees.present?
      base_fee = fees.base_fee
      transaction_fee = fees.transaction_fee
    end

    if fees.present?
      amount = fees.base_fee
    end
    if personalized_discount.present?
      if personalized_discount.is_discount_percent
        amount =  amount - ((personalized_discount.discount * amount) / 100)
      else
        amount =  amount - personalized_discount.discount
      end
    end

    if fees.present?
      if fees.is_transaction_fee_percent
        amount =  amount + ((fees.transaction_fee * amount) / 100)
      else
        amount = amount + fees.transaction_fee
      end
    end

    json_response({event_fee: {base_fee: base_fee, transaction_fee: transaction_fee }, personalized_discount: personalized_discount,
                   amount: amount})
  end

  private

  def fees_params
    params.required(:base_fee)
    params.required(:transaction_fee)
    params.permit(:base_fee, :transaction_fee)
  end

  def calculate_params
    params.permit(:code)
  end

  def discounts_params
    unless params[:discounts].nil? and !params[:discounts].kind_of?(Array)
      params[:discounts].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:id, :name, :email, :code, :discount)
      end
    end
  end
end
