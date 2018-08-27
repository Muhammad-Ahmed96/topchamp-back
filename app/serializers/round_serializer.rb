class RoundSerializer < ActiveModel::Serializer
  attributes :id, :index,:status
  belongs_to :tournament, :serializer => TournamentSerializer
  has_many :matches, :serializer => MatchSerializer
end
