class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :skill_level, :status, :categories, :sports
  belongs_to :user, serializer: UserSingleSerializer
  belongs_to :event, serializer: EventSingleSerializer

  has_many :brackets

  def categories
    categories = []
    object.brackets.each {|bracket| categories << bracket.category if categories.detect{|w| w.id == bracket.category.id}.nil? }
    categories
  end

  def sports
    object.user.sports
  end
end
