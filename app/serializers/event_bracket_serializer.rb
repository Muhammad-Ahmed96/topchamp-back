class EventBracketSerializer < ActiveModel::Serializer
  attributes :id, :age, :lowest_skill, :highest_skill, :quantity
  has_many :brackets
end
