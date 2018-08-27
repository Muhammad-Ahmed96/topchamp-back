class SetsControllerController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!

  def create
    match = Match.find(score_save_params[:match_id])
    data = {:index => score_save_params[:index]}
    set = match.sets.where(:index => score_save_params[:index]).update_or_create!(data)
    data = {:score => score_save_params[:score], :time_out => score_save_params[:time_out],
                   :team_id => score_save_params[:team_id]}
    score = set.score.where(:team_id => score_save_params[:tem_id]).update_or_create!(data)
    json_response_success("Score saved", true)
  end

  private
  def score_save_params
    params.require(:match_id)
    params.require(:index)
    params.require(:score)
    params.require(:time_out)
    params.require(:team_id)
    params.permit(:match_id,:set_index, :score, :time_out, :team_id)
  end
end
