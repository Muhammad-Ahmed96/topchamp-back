class EventBracketStatusSerializer < ActiveModel::Serializer
  attributes :id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :status
  has_many :brackets, serializer: EventBracketStatusSerializer

  def brackets
    brackets = []
      object.brackets.age_filter(object.user_age, object.event.sport_regulator.allow_age_range).skill_filter(object.user_skill).each do  |bracket|
        bracket.user_age = object.user_age
        bracket.user_skill = object.user_skill
        brackets << bracket
      end
    brackets
  end
end
