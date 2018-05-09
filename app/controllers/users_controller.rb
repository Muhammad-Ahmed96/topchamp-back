class UsersController < ApplicationController
  before_action :set_resource, only: [:show, :update, :destroy]

  def index
    paginate User.unscoped, per_page: 50, root: :data
  end
  def create
    resource = User.create!(resource_params)
    json_response_data(resource)
  end

  def show
    json_response_data(@resource)
  end

  def update
    @resource.update!(resource_params)
    json_response_data(@resource)
  end

  def destroy
    @resource.destroy
    json_response_success(t(:deleted), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:first_name, :middle_initial, :last_name, :badge_name, :birth_date, :email, :role, :gender)
  end

  def set_resource
    @resource = User.find(params[:id])
  end
end
