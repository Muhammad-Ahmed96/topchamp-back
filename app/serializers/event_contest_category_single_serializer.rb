class EventContestCategorySingleSerializer < ActiveModel::Serializer
  attributes :id, :category_id, :name,:bracket_types

  def category_id
    object.category.id
  end
  def name
    object.category.name
  end
end
