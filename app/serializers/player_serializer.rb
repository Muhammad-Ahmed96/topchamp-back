class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status, :categories, :brackets, :sports
  belongs_to :user, serializer: UserSingleSerializer
  belongs_to :event, serializer: EventSingleSerializer

  def categories
    categories = []
    object.event_enrolls.each {|enroll| categories << enroll.category}
    categories
  end
  
  def brackets
    brackets = []
    object.event_enrolls.each {|enroll| brackets << enroll.bracket_skill if enroll.bracket_skill.present?}
    object.event_enrolls.each {|enroll| brackets << enroll.bracket_age if enroll.bracket_age.present?}
    brackets
  end

  def sports
    object.user.sports
  end
end
