class EventBracketAgeSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :event_bracket_skill_id, :age, :quantity, :available_for_enroll

  has_many :bracket_skills, serializer: EventBracketSkillSerializer
end
