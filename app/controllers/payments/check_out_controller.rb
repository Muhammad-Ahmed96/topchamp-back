class Payments::CheckOutController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def event

  end
end
