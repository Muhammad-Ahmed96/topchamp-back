class EventBracketStatusSerializer < ActiveModel::Serializer
  attributes :id, :age, :lowest_skill, :highest_skill, :quantity, :status
  has_many :brackets, serializer: EventBracketStatusSerializer
end
