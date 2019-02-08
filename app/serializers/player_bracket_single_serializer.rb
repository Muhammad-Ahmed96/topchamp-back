class PlayerBracketSingleSerializer < ActiveModel::Serializer
  attributes :id, :player_id, :category_id, :event_bracket_id, :enroll_status
  belongs_to :category, serializer: CategorySerializer
  belongs_to :bracket, serializer: EventBracketSerializer

end
