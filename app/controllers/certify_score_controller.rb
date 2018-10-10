require 'fcm'
class CertifyScoreController < ApplicationController
  include Swagger::Blocks
  before_action :authenticate_user!
  around_action :transactions_filter, only: [:create]
  swagger_path '/certify_score' do
    operation :post do
      key :summary, 'Save a certify score'
      key :description, 'Certify score'
      key :operationId, 'certifyScoreSave'
      key :produces, ['application/json',]
      key :tags, ['certify_score']
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
          key :'$ref', :SuccessModel
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
    match = Match.find(create_params[:match_id])
    if match.present?
      match.team_winner.players.each do |player|
        certified_score = CertifiedScore.where(:match_id => match.id).where(:user_id => player.user_id)
                              .update_or_create!({:match_id => match.id, :round_id => match.round.id, :event_id => match.round.tournament.event.id,
                                                  :tournament_id => match.round.tournament.id, :team_a_id => match.team_a_id, :team_b_id => match.team_b_id,
                                                  :team_winner_id => match.team_winner_id, :user_id => player.user_id, :date_at => DateTime.now,
                                                  :status => :pending})
        options = {data: {message: t("events.certifi_score"), id: certified_score.id}, collapse_key: "updated_score", notification: {
            body: t("events.certifi_score"), sound: 'default'}}
        send_push(options)
      end
      json_response_success(t("created_success", model: CertifiedScore.model_name.human), true)
    end
  end

  swagger_path '/certify_score/:id' do
    operation :get do
      key :summary, 'Show a certify score'
      key :description, 'Certify score'
      key :operationId, 'certifyScoreShow'
      key :produces, ['application/json',]
      key :tags, ['certify_score']
      response 200 do
        key :required, [:data]
        schema do
          property :data do
            key :'$ref', :CertifiedScore
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

  def show
    certified_score = CertifiedScore.find(params[:id])
    json_response_serializer(certified_score, CertifiedScoreSerializer)
  end

  swagger_path '/certify_score/:id' do
    operation :put do
      key :summary, 'Update a certify score'
      key :description, 'Certify score'
      key :operationId, 'certifyScoreUpdate'
      key :produces, ['application/json',]
      key :tags, ['certify_score']
      parameter do
        key :name, :signature
        key :in, :body
        key :required, true
        key :type, :string
        key :format, :file
      end
      response 200 do
        key :description, ''
        schema do
          key :'$ref', :SuccessModel
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

  def update
    certified_score = CertifiedScore.find(params[:id])
    certified_score.signature = update_params[:signature]
    certified_score.status = :signed
    certified_score.save!(:validate => false)
    json_response_success(t("edited_success", model: CertifiedScore.model_name.human), true)
  end

  private

  def create_params
    params.require(:match_id)
    params.permit(:match_id)
  end

  def update_params
    params.require(:signature)
    params.permit(:signature)
  end
end
