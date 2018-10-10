class CertifiedScoreSerializer < ActiveModel::Serializer
  def initialize(*args)
    super
    instance_options[:match_id] = object.match_id
  end
  attributes :id, :match_id, :event_id, :tournament_id, :round_id, :team_a_id, :team_b_id, :team_winner_id, :user_id,:created_at ,
             :signature, :status
  belongs_to :user, :serializer => UserSingleSerializer
  belongs_to :event, :serializer => EventSingleSerializer
  belongs_to :tournament, :serializer => TournamentWithTotalSerializer
  belongs_to :team_a, :serializer => TeamScoreSerializer
  belongs_to :team_b, :serializer => TeamScoreSerializer
  belongs_to :team_winner, :serializer => TeamScoreSerializer
end
