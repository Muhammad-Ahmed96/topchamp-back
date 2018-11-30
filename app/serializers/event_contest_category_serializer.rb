class EventContestCategorySerializer < ActiveModel::Serializer
  attributes :id, :name,:bracket_types
  belongs_to :brackets, serializer: EventContestCategoryBracketSerializer

  def id
    object.category.id
  end

  def name
    object.category.name
  end
end
