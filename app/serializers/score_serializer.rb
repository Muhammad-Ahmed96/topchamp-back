class ScoreSerializer < ActiveModel::Serializer
  attributes :id, :score, :time_out
  has_one :team, serializer: TeamSingleSerializer
end
