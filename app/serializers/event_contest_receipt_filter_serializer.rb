class EventContestReceiptFilterSerializer < ActiveModel::Serializer
  attributes :id, :index
  has_many :categories, serializer: EventContestReceiptFilterCategorySerializer

  def categories
    object.filter_categories
  end
end