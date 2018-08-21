class TournamentsController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_event, only: [:players_list, :create, :teams_list, :rounds_list, :matches, :index]

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

  swagger_path '/events/:event_id/tournaments' do
    operation :get do
      key :summary, 'Get tournament '
      key :description, 'Event Catalog'
      key :operationId, 'tournamentsIndex'
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
    paginate = params[:paginate].nil? ? '1' : params[:paginate]
    tournaments = @event.tournaments
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
              key :'$ref', :Raund
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
