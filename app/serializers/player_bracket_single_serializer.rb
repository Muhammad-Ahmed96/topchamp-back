class PlayerBracketSingleSerializer < ActiveModel::Serializer
  attributes :id, :age, :lowest_skill, :highest_skill
  belongs_to :category, serializer: CategorySerializer
  has_one :parent_bracket, serializer: EventBracketSingleSerializer

  def id
    object.bracket.id
  end

  def age
    object.bracket.age
  end

  def lowest_skill
    object.bracket.lowest_skill
  end

  def highest_skill
    object.bracket.highest_skill
  end

  def quantity
    object.bracket.quantity
  end

  def parent_bracket
    EventBracket.where(:id => object.bracket.event_bracket_id).first
  end

end
