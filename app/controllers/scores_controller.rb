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
        key :name, :scores_a
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :'$ref', :ScoreInput
        end
      end
      parameter do
        key :name, :scores_b
        key :in, :body
        key :required, true
        key :type, :array
        items do
          key :'$ref', :ScoreInput
        end
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
    if score_save_params[:scores_a].kind_of?(Array)
      score_save_params[:scores_a].each do |item|
        data = {:number => item[:number_set]}
        set = match.sets.where(:number => data[:number]).first_or_create!(data)
        data = {:score => item[:score], :time_out => item[:time_out],
                :team_id => match.team_a_id}
        score = set.scores.where(:team_id => data[:team_id]).update_or_create!(data)
        match.update!({:referee => score_save_params[:referee]})
      end
    end

    if score_save_params[:scores_b].kind_of?(Array)
      score_save_params[:scores_b].each do |item|
        data = {:number => item[:number_set]}
        set = match.sets.where(:number => data[:number]).first_or_create!(data)
        data = {:score => item[:score], :time_out => item[:time_out],
                :team_id =>  match.team_b_id}
        score = set.scores.where(:team_id => data[:team_id]).update_or_create!(data)
      end
    end


    round = match.round
    tournament = round.tournament
    tournament.set_winner(match)

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
    scores = Score.joins(set: [match: [round: [tournament: :event ]]])
                 .merge(MatchSet.where(:match_id => score_list_params[:match_id])).all
    json_response_serializer_collection(scores, ScoreSerializer)
  end

  swagger_path '/events/:id/scores/match_details' do
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
  def match_details
    match = Match.find(score_list_params[:match_id])
    json_response(match)
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
    params.require(:scores_a)
    params.require(:scores_b)
   # params.require(:referee)
    params.permit(:match_id, :referee, scores_a: [:number_set, :score, :time_out], scores_b: [:number_set, :score, :time_out])
  end
end
