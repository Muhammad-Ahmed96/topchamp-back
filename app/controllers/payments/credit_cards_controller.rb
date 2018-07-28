class Payments::CreditCardsController < ApplicationController
  include Swagger::Blocks
  include AuthorizeNet::API
  before_action :authenticate_user!

  swagger_path '/payments/credit_cards' do
    operation :get do
      key :summary, 'Get credit cards list'
      key :description, 'Credit Cards'
      key :operationId, 'paymentsCreditCardsIndex'
      key :produces, ['application/json',]
      key :tags, ['payments credit cards']
      response 200 do
        schema do
          property :data do
            key :'$ref', :PaymentProfile
          end
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
    json_response_data(Payments::PaymentProfile.getItemsFormat(Payments::Customer.get(@resource).profile.paymentProfiles))
  end
  swagger_path '/payments/credit_cards' do
    operation :post do
      key :summary, 'Save credit card'
      key :description, 'Credit Cards'
      key :operationId, 'paymentsCreditCardsCreate'
      key :produces, ['application/json',]
      key :tags, ['payments credit cards']
      parameter do
        key :name, :card_number
        key :in, :body
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :expiration_date
        key :in, :body
        key :description, 'Use YYYY-MM Format'
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
  def create
    Payments::Customer.get(@resource)
    user = User.find(@resource.id)
    response = Payments::PaymentProfile.create(user, create_params[:card_number], create_params[:expiration_date])
    json_response_success(response.customerPaymentProfileId, 200)
  end
  swagger_path '/payments/credit_cards/:id' do
    operation :delete do
      key :summary, 'Delete credit card'
      key :description, 'Credit Cards'
      key :operationId, 'paymentsCreditCardsDestroy'
      key :produces, ['application/json',]
      key :tags, ['payments credit cards']
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
  def destroy
    response = Payments::PaymentProfile.delete(Payments::Customer.get(@resource).profile.customerProfileId, params[:id])
    if response.messages.resultCode != MessageTypeEnum::Ok
      return json_response_error([response.messages.messages[0].text], 422, response.messages.messages[0].code)
    end
    json_response_success(t("deleted_success", model: "Credit Card"), true)
  end

  private

  def create_params
    params.permit(:card_number, :expiration_date)
  end
end
