class EventBracketSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :start_date, :time_start, :time_end
  has_many :brackets, serializer: EventContestCategoryBracketDetailSerializer
end
