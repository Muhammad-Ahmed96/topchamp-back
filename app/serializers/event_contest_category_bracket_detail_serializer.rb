class EventContestCategoryBracketDetailSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity
  has_many :brackets, serializer: EventContestCategoryBracketDetailSerializer
end
