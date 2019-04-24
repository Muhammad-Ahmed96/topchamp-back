class PlayerListSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status, :signature
  belongs_to :user, serializer: UserListSerializer
end
