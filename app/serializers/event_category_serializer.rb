class EventCategorySerializer < ActiveModel::Serializer
  attributes :id, :name
  #has_many :brackets, serializer: EventBracketStatusSerializer
end
