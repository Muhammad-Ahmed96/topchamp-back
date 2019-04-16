class TeamsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_event, only: [:index, :create]
  before_action :set_resource, only: [:destroy]
  def index
    column = params[:column].nil? ? 'id' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    paginate = params[:paginate].nil? ? '1' : params[:paginate]

    in_id = params[:id]
    contest_index = params[:contest]
    category_in = params[:category]
    category_like = params[:category_like]
    player_1_like = params[:player_1]
    player_2_like = params[:player_2]
    bracket_like = params[:bracket]

    contest_order = nil
    if column == 'contest'
      contest_order = 'contest_index'
      column = nil
    end

    categories_order = nil
    if column == 'category'
      categories_order = 'name'
      column = nil
    end

    player_1_order = nil
    if column == 'player_1'
      player_1_order = 'first_name'
      column = nil
    end

    player_2_order = nil
    if column == 'player_2'
      player_2_order = 'first_name'
      column = nil
    end

    bracket_order = nil
    if column == 'bracket'
      bracket_order = 'bracket'
      column = nil
    end

    teams = @event.teams.in_id(in_id).contest_index(contest_index).category_in(category_in).category_like(category_like)
    .player_1_like(player_1_like).player_2_like(player_2_like).bracket_like(bracket_like)
    .my_order(column, direction).categories_order(categories_order, direction).contest_order(contest_order, direction)
                .contest_order(contest_order, direction).player_1_order(player_1_order, direction).player_2_order(player_2_order, direction)
                .bracket_order(bracket_order, direction)
    if paginate.to_s == "0"
      json_response_serializer_collection(teams.all, TeamListSerializer)
    else
      paginate teams, per_page: 50, root: :data,  each_serializer: TeamListSerializer
    end
  end

  def create
    player1 = Player.find(create_params[:player_1_id])
    player2 = Player.find(create_params[:player_2_id])
    bracket = EventContestCategoryBracketDetail.find(create_params[:bracket_id])

    bracket_player = player1.brackets.where(:event_bracket_id => bracket.id).first!

    bracket_player.is_root = true
    bracket_player.partner_id = player2.user_id
    bracket_player.save!
    User.create_teams([bracket_player], player1.user_id, @event_id)
    json_response_success(t("created_success", model: Player.model_name.human), true)
  end

  def destroy
    players = []
     @team.players.each do |player|
       player.teams.destroy(@team)
       player.save
       players.push(player)
     end
    players.each do |player|
      User.create_team(player.user_id, @team.event_id, @team.event_bracket_id, @team.category_id, [player.id])
    end
     @team.destroy
    json_response_success(t("deleted_success", model: Team.model_name.human), true)
  end

  private
  def set_event
    # @event =  policy_scope(Event).find(params[:event_id])
    @event =  Event.find(params[:event_id])
  end

  def set_resource
    # @team = Event.find(params[:event_id]).teams.where(:id => params[:id]).first!
    @team = Event.find(params[:event_id]).teams.where(:id => params[:id]).first!
  end

  def create_params
    params.required(:event_id)
    params.required(:bracket_id)
    params.required(:player_1_id)
    params.required(:player_2_id)
    params.permit(:event_id, :bracket_id, :player_1_id, :player_2_id)
  end
end
