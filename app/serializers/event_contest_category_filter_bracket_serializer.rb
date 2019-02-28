class EventContestCategoryFilterBracketSerializer < ActiveModel::Serializer
  attributes :id, :awards_for, :awards_through, :awards_plus, :bracket_type, :bracket, :has_players
  has_many :details, serializer: EventContestCategoryBracketDetailFilterSerializer

  def details
    object.filter_details
  end

  def bracket
    unless object.bracket_type.nil?
      Bracket.collection[object.bracket_type.to_sym]
    end
  end
end
