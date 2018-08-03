class EventBracketSingleSerializer < ActiveModel::Serializer
  attributes :id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity
end
