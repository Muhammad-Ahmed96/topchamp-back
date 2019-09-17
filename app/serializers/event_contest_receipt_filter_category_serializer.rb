class EventContestReceiptFilterCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :bracket_types
  has_many :brackets, serializer: EventContestCategoryReceiptFilterBracketSerializer

  def id
    object.category.id
  end

  def name
    object.category.name
  end

  def brackets
    object.filter_brackets
  end
end