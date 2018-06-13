class EventBracketAgeSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :event_bracket_skill_id, :age, :quantity

  has_many :bracket_skills, serializer: EventBracketSkillSerializer
end
