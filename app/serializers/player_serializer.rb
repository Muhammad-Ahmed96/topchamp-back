class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status
  belongs_to :user, serializer: UserSingleSerializer
  belongs_to :event, serializer: EventSingleSerializer

  has_many :brackets, serializer: PlayerBracketSingleSerializer
  has_many :categories, serializer: CategorySerializer
  has_many :sports, serializer: SportSerializer
end
