class MatchSerializer < ActiveModel::Serializer
  attributes :id, :index, :team_a_id, :team_b_id,:status
  belongs_to :team_a, serializer: TeamSingleSerializer
  belongs_to :team_b, serializer: TeamSingleSerializer
end
