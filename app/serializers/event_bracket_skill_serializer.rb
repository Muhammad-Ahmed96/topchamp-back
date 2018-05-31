class EventBracketSkillSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :event_bracket_age_id, :lowest_skill, :highest_skill, :quantity

  has_many :bracket_ages, serializer: EventBracketAgeSerializer, include: true, type:    'my_other_app_module_product'
end
