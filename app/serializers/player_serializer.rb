class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status, :signature
  belongs_to :user, serializer: UserSingleSerializer
  belongs_to :event, serializer: EventSingleSerializer

  has_many :brackets, serializer: PlayerBracketSingleSerializer
  has_many :brackets_enroll, serializer: PlayerBracketSingleSerializer
  #has_many :brackets_wait_list, serializer: PlayerBracketSingleSerializer, key: :wait_list
  has_many :categories, serializer: CategorySerializer
  has_many :sports, serializer: SportSerializer
  has_many :schedules, serializer: EventScheduleSerializer
end
