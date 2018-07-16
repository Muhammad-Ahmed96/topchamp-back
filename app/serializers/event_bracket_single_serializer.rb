class EventBracketSingleSerializer < ActiveModel::Serializer
  attributes :id, :age, :lowest_skill, :highest_skill, :quantity
end
