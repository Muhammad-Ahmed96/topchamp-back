class EventBracketStatusSerializer < ActiveModel::Serializer
  attributes :id, :age, :lowest_skill, :highest_skill, :quantity, :status
  has_many :brackets, serializer: EventBracketStatusSerializer

  def brackets
    brackets = []
      object.brackets.age_filter(object.user_age).skill_filter(object.user_skill).each do  |bracket|
        bracket.user_age = object.user_age
        bracket.user_skill = object.user_skill
        bracket.category_id = object.category_id
        bracket.status = bracket.available_for_enroll(object.category_id)
        brackets << bracket
      end
    brackets
  end
end
