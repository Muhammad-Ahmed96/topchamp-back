class TeamSingleSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :players, :serializer => PlayerSingleSerializer
end
