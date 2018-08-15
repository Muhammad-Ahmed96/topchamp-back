class TournamentSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :event_bracket_id, :category_id, :status

  belongs_to :event, :serializer => EventSingleSerializer
  belongs_to :bracket, :serializer => EventBracketSerializer
  belongs_to :category, :serializer => CategorySerializer
  has_many :rounds, :serializer => RoundSingleSerializer
end
