class TeamSingleSerializer < ActiveModel::Serializer
  attributes :id
  has_many :players, :serializer => PlayerSingleSerializer
end
