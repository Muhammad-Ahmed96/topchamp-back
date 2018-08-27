class ScoresController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  before_action :set_event, only: [:create, :index]
  around_action :transactions_filter, only: [:create]
  swagger_path '/events/:id/scores' do
    operation :post do
      key :summary, 'Save score match'
      key :description, 'Event Catalog'
      key :operationId, 'scoreSave'
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
        key :name, :match_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :number
        key :description, "Number of set"
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      parameter do
        key :name, :score
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :time_out
        key :in, :body
        key :required, true
        key :type, :number
      end
      parameter do
        key :name, :team_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :type, :string
            end
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
    match = Match.joins(round: [tournament: :event ]).merge(Event.where(:id => @event.id)).where(:id => score_save_params[:match_id]).first!()
    data = {:number => score_save_params[:number]}
    set = match.sets.where(:number => data[:number]).first_or_create!(data)
    data = {:score => score_save_params[:score], :time_out => score_save_params[:time_out],
            :team_id => score_save_params[:team_id]}
    score = set.scores.where(:team_id => score_save_params[:team_id]).update_or_create!(data)
=begin
    round = match.round
    tournament = round.tournament
    tournament.set_winner(match)
=end
    json_response_success("Score saved", true)
  end

  swagger_path '/events/:id/scores' do
    operation :get do
      key :summary, 'List score match'
      key :description, 'Event Catalog'
      key :operationId, 'scoreIndex'
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
        key :name, :match_id
        key :in, :body
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, ''
        schema do
          property :data do
            items do
              key :type, :string
            end
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
    scores = Score.joins(set: [match: [round: [tournament: :event ]]]).merge(Event.where(:id => @event.id))
                 .merge(MatchSet.where(:match_id => score_list_params[:match_id])).all
    json_response_serializer_collection(scores, ScoreSerializer)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
  def score_list_params
    params.require(:match_id)
    params.permit(:match_id)
  end
  def score_save_params
    params.require(:match_id)
    params.require(:number)
    params.require(:score)
    params.require(:time_out)
    params.require(:team_id)
    params.permit(:match_id,:number, :score, :time_out, :team_id)
  end
end
