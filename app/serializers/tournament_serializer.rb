class TournamentSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :event_bracket_id, :category_id, :status, :teams_count, :matches_status, :winner_team_id,
             :contest_id

  belongs_to :event, :serializer => EventSingleSerializer
  belongs_to :bracket, :serializer => EventBracketSerializer
  belongs_to :category, :serializer => CategorySerializer
  has_many :rounds, :serializer => RoundSingleSerializer
  has_many :rounds_losers, :serializer => RoundSingleSerializer
  has_many :rounds_final, :serializer => RoundSingleSerializer
  has_one :winner_team, :serializer => TeamSingleSerializer
end
