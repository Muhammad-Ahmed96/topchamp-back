class TournamentRoundsSerializer < ActiveModel::Serializer
  has_many :rounds, :serializer => RoundSingleSerializer
  has_many :rounds_losers, :serializer => RoundSingleSerializer
  has_many :rounds_final, :serializer => RoundSingleSerializer
end
