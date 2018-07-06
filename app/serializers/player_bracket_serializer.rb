class PlayerBracketSerializer < ActiveModel::Serializer
  attributes :id, :player_id, :category_id, :event_bracket_age_id, :event_bracket_skill_id

  belongs_to :bracket_skill, serializer: EventBracketSkillSerializer
  belongs_to :bracket_age, serializer: EventBracketAgeSerializer
  belongs_to :category, serializer: CategorySerializer
end
