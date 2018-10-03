class RivalInfoSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status, :signature
  belongs_to :user, serializer: UserSingleSerializer

end
