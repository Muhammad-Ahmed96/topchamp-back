class MatchSerializer < ActiveModel::Serializer
  attributes :id, :index, :team_a_id, :team_b_id,:status, :seed_team_a, :seed_team_b
  belongs_to :team_a, serializer: TeamSingleSerializer
  belongs_to :team_b, serializer: TeamSingleSerializer
end
