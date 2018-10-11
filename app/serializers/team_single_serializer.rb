class TeamSingleSerializer < ActiveModel::Serializer
  attributes :id, :name, :general_score, :match_won
  has_many :players, :serializer => PlayerSingleSerializer
end
