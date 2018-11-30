class EventContestCategoryBracketSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :bracket_type
  has_many :brackets
end
