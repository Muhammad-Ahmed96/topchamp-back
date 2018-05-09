class UsersController < ApplicationController
  def create
    @user = User.create!(resource_params)
    json_response(@todo, :created)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:first_name, :middle_initial, :last_name, :badge_name, :birth_date, :email, :role)
  end
end
