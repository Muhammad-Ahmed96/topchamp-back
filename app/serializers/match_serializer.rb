class MatchSerializer < ActiveModel::Serializer
  def initialize(*args)
    super
    unless object.nil?
      instance_options[:match_id] = object.id
    end
  end
  attributes :id, :index, :round_id, :team_a_id, :team_b_id,:status, :seed_team_a, :seed_team_b, :match_number,
             :court, :date, :start_time, :end_time, :team_winner_id, :referee
  belongs_to :team_a, serializer: TeamScoreSerializer
  belongs_to :team_b, serializer: TeamScoreSerializer

  has_many :sets, serializer: SetSerializer


end
