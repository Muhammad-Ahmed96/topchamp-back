class SportsController < ApplicationController
  before_action :set_resource, only: [:show, :update, :destroy]

  def index
    json_response_data(Sport.all, :created)
    #paginate Sport.unscoped, per_page: 50
  end

  def create
    resource = Sport.create!(resource_params)
    json_response_data(resource, :created)
  end

  def show
    json_response_data(@resource)
  end

  def update
    @resource.update!(resource_params)
    json_response_data(@resource, :updated)
  end

  def destroy
    @resource.destroy
    json_response_success(t(:deleted), true)
  end

  private

  def resource_params
    # whitelist params
    params.permit(:name)
  end

  def set_resource
    @resource = Sport.find(params[:id])
  end
end
