class EventBracketParentSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity
  has_many :brackets
  has_one :parent_bracket, serializer: EventBracketSingleSerializer
  def parent_bracket
    unless object.nil?
      EventBracket.where(:id => object.event_bracket_id).first
    end
  end
end
