class PlayerBracketSingleSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age,:old_age, :lowest_skill, :highest_skill, :enroll_status
  belongs_to :category, serializer: CategorySerializer
  has_one :parent_bracket, serializer: EventBracketSingleSerializer

  def id
    unless object.bracket.nil?
      object.bracket.id
    end
  end

  def age
    unless object.bracket.nil?
      object.bracket.age
    end
  end

  def young_age
    unless object.bracket.nil?
      object.bracket.young_age
    end
  end


  def old_age
    unless object.bracket.nil?
      object.bracket.old_age
    end
  end

  def lowest_skill
    unless object.bracket.nil?
      object.bracket.lowest_skill
    end
  end

  def highest_skill
    unless object.bracket.nil?
      object.bracket.highest_skill
    end
  end

  def quantity
    unless object.bracket.nil?
      object.bracket.quantity
    end
  end

  def parent_bracket
    unless object.bracket.nil?
      EventBracket.where(:id => object.bracket.event_bracket_id).first
    end
  end

end
