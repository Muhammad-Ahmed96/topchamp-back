class SetSerializer < ActiveModel::Serializer
  attributes :id, :number
  #belongs_to :match, serializer: MatchSerializer
  has_many :scores, serializer: ScoreSerializer
end
