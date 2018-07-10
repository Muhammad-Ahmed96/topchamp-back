class PlayerBracketSerializer < ActiveModel::Serializer
  attributes :id, :player_id, :category_id, :event_bracket_age_id, :event_bracket_skill_id
  belongs_to :category, serializer: CategorySerializer
end
