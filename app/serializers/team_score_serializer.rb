class TeamScoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :general_score, :match_won
  has_many :players, :serializer => PlayerSingleSerializer
  has_many :scores, :serializer => ScoreSingleSerializer
  def scores
    scores = []
    if instance_options[:match_id].present?
    scores = Score.joins(set: [match: [round: [tournament: :event ]]])
                 .merge(MatchSet.where(:match_id => instance_options[:match_id])).where(:team_id => object.id).all
      end
  end
end
