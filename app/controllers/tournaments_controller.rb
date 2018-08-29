class TournamentsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_event, only: [:players_list, :create, :teams_list, :rounds_list, :matches, :details]

  swagger_path '/events/:event_id/tournaments/players' do
    operation :get do
      key :summary, 'Get player list event tournament'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsPlayerList'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Player Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Player
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def players_list
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    players = @event.players.joins(:brackets).merge(PlayerBracket.where(:event_bracket_id => players_list_params[:bracket_id])
    .where(:category_id => players_list_params[:category_id]))
    if paginate.to_s == "0"
      json_response_serializer_collection(players.all, PlayerSingleSerializer)
    else
      paginate players, per_page: 50, root: :data
    end
  end

  swagger_path '/events/:event_id/tournaments/teams' do
    operation :get do
      key :summary, 'Get teams list event tournament'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsTeamsList'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Team Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Team
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def teams_list
      paginate = params[:paginate].nil? ? '1' : params[:paginate]
      teams = @event.teams.where(:event_bracket_id => players_list_params[:bracket_id]).where(:category_id => players_list_params[:category_id])
      if paginate.to_s == "0"
        json_response_serializer_collection(teams.all, TeamSerializer)
      else
        paginate teams, per_page: 50, root: :data
      end
  end

  swagger_path '/events/:event_id/tournaments' do
    operation :post do
      key :summary, 'Save tournament and matches'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsSave'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end

      parameter do
        key :name, :rounds
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :'$ref', :RoundInput
        end
      end
      response 200 do
        key :description, 'Tournament Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Tournament
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def create
    tournament = Tournament.where(:event_id => @event.id).where(:event_bracket_id => players_list_params[:bracket_id])
                     .where(:category_id => players_list_params[:category_id]).first_or_create!
    if rounds_params.present?
      tournament.sync_matches!(rounds_params)
    end

    json_response_serializer(tournament, TournamentSerializer)
  end

  swagger_path '/tournaments' do
    operation :get do
      key :summary, 'Get tournaments '
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsIndex'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :column
        key :in, :query
        key :description, 'Column to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :direction
        key :in, :query
        key :description, 'Direction to order'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :event_id
        key :in, :query
        key :description, 'Event filter'
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :event
        key :in, :query
        key :description, 'Title of event filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :description, 'Category filter'
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :description, 'Bracket filter'
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :bracket
        key :in, :query
        key :description, 'Bracket age or lowest_skill or highest_skillm or young_age or old_age'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :teams_count
        key :in, :query
        key :description, 'Teams count filter'
        key :required, false
        key :type, :int64
      end
      parameter do
        key :name, :matches_status
        key :in, :query
        key :description, 'Assigned matches status filter'
        key :required, false
        key :type, :string
      end
      parameter do
        key :name, :paginate
        key :in, :query
        key :description, 'paginate {any} = paginate, 0 = no paginate'
        key :required, false
        key :type, :integer
      end
      response 200 do
        key :description, 'Tournament Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Tournament
            end
            key :description, "Information container"
          end
          property :meta do
            key :'$ref', PaginateModel
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def index
    authorize Event
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    column = params[:column].nil? ? 'title' : params[:column]
    direction = params[:direction].nil? ? 'asc' : params[:direction]
    event_id = params[:event_id]
    event = params[:event]
    matches_status = params[:matches_status]
    category_id = params[:category_id]
    bracket_id = params[:bracket_id]
    bracket = params[:bracket]
    teams_count = params[:teams_count]

    order_event = nil
    order_category = nil
    order_bracket = nil
    if column.to_s == "title"
      order_event = column
      column = nil
    end

    if column.to_s == "name"
      order_category = column
      column = nil
    end

    if column.to_s == "bracket"
      order_bracket = column
      column = nil
    end


    tournaments = TournamentPolicy::Scope.new(current_user, Tournament).resolve.my_order(column, direction).matches_status_in(matches_status).event_in(event_id).category_in(category_id)
    .bracket_in(bracket_id).bracket_like(bracket).event_order(order_event, direction).category_order(order_category, direction).bracket_order(order_bracket, direction)
    .teams_count_in(teams_count).event_like(event)
    if paginate.to_s == "0"
      json_response_serializer_collection(tournaments.all, TournamentSerializer)
    else
      paginate tournaments, per_page: 50, root: :data, each_serializer: TournamentSerializer
    end
  end

  swagger_path '/events/:event_id/tournaments/rounds' do
    operation :get do
      key :summary, 'Get rounds list event tournament'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsRondsList'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Raound Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Round
            end
            key :description, "Information container"
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def rounds_list
    tournament = Tournament.where(:event_id => @event.id).where(:event_bracket_id => players_list_params[:bracket_id])
                     .where(:category_id => players_list_params[:category_id]).first_or_create!
    json_response_serializer_collection(tournament.rounds, RoundSingleSerializer)
  end


  swagger_path '/events/:event_id/tournaments/details' do
    operation :get do
      key :summary, 'Get tournament details'
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsDetails'
      key :produces, ['application/json',]
      key :tags, ['events']
      parameter do
        key :name, :event_id
        key :in, :path
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :category_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :bracket_id
        key :in, :query
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'Tournament Respone'
        schema do
          key :type, :object
          property :data do
            key :type, :array
            items do
              key :'$ref', :Round
            end
            key :description, "Information container"
          end
        end
      end
      response 401 do
        key :description, 'not authorized'
        schema do
          key :'$ref', :ErrorModel
        end
      end
      response :default do
        key :description, 'unexpected error'
      end
    end
  end
  def details
    tournament = Tournament.where(:event_id => @event.id).where(:event_bracket_id => players_list_params[:bracket_id])
                     .where(:category_id => players_list_params[:category_id]).first_or_create!
    json_response_serializer(tournament, TournamentWithTeamsSerializer)
  end
  private
  def set_event
    @event = Event.find(params[:event_id])
  end
  
  def players_list_params
    params.required(:category_id)
    params.required(:bracket_id)
    params.permit(:category_id, :bracket_id)
  end

  def rounds_params
    unless params[:rounds].nil? and !params[:rounds].kind_of?(Array)
      params[:rounds].map do |p|
        ActionController::Parameters.new(p.to_unsafe_h).permit(:index, matches:[:index, :team_a_id, :team_b_id, :seed_team_a, :seed_team_b])
      end
    end
  end
end
