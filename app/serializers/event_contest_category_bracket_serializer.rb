class EventContestCategoryBracketSerializer < ActiveModel::Serializer
  attributes :id,:awards_for, :awards_through, :awards_plus, :bracket_type, :has_players
  has_many :details, serializer: EventContestCategoryBracketDetailSerializer
end
