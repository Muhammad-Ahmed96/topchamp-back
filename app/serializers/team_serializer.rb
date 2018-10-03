class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :players, :serializer => PlayerSingleSerializer
  belongs_to :event,  :serializer => EventSingleSerializer
  belongs_to :bracket, :serializer => EventBracketSerializer
  belongs_to :category, :serializer => CategorySerializer
end
