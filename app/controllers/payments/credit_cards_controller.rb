class Payments::CreditCardsController < ApplicationController
  before_action :authenticate_user!


  def index
    json_response_data(Payments::PaymentProfile.getItemsFormat(customer.profile.paymentProfiles))
  end

  def create
    customer
    user = User.find(@resource.id)
    response = Payments::PaymentProfile.create(user, create_params[:card_number], create_params[:expiration_date])
    json_response_success(response.customerPaymentProfileId, 200)
  end

  private

  def create_params
    params.permit(:card_number, :expiration_date)
  end

  def customer
    profile = Payments::Profile.get(@resource.customer_profile_id)
    if profile.nil?
      profile = Payments::Profile.create(@resource)
    end
    return profile
  end
end
