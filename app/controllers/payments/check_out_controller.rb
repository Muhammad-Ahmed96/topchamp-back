class Payments::CheckOutController < ApplicationController
  before_action :authenticate_user!
end
