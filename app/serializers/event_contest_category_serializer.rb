class EventContestCategorySerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name,:bracket_types, :has_players
  belongs_to :brackets, serializer: EventContestCategoryBracketSerializer

  def category_id
    object.category.id
  end

  def name
    object.category.name
  end
end
