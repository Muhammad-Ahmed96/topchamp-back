class MatchSerializer < ActiveModel::Serializer
  def initialize(*args)
    super
    instance_options[:match_id] = object.id
  end
  attributes :id, :index, :team_a_id, :team_b_id,:status, :seed_team_a, :seed_team_b, :match_number,
             :court, :date, :start_time, :end_time, :team_winner_id
  belongs_to :team_a, serializer: TeamScoreSerializer
  belongs_to :team_b, serializer: TeamScoreSerializer

  has_many :sets, serializer: SetSerializer


end
