class WaitListSerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :bracket, serializer: EventBracketSerializer
  belongs_to :category, serializer: CategorySerializer
end
