class RoundSingleSerializer < ActiveModel::Serializer
  attributes :id, :index, :status
  has_many :matches, :serializer => MatchSerializer
end
