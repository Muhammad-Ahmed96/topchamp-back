class MatchController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def find_by_number
    match = Match.where(:match_number => find_by_number_params[:number]).first!
    json_response(match)
  end
  private
  def find_by_number_params
    params.require(:number)
    params.permit(:number)
  end
end
