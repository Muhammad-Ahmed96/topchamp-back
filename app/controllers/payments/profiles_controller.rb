class Payments::ProfilesController < ApplicationController
  before_action :authenticate_user!
  def create
    exist = Payments::Profile.get(@resource.customer_profile_id)
    if exist.present?
      return response_error_profile_exist
    end
    response = Payments::Profile.create(@resource)
    json_response_success(response.customerProfileId, 200)
  end

  def show
    exist = Payments::Profile.get(@resource.customer_profile_id)
    json_response_success(exist, 200)
  end

  def destroy
    response = Payments::Profile.delete("1914872509")
    json_response_success(response.messages.resultCode, 200)
  end

  private

  def response_error_profile_exist
    json_response_error(["Profile already exists"])
  end

end
