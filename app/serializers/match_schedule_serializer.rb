class MatchScheduleSerializer < ActiveModel::Serializer
  attributes :id,:title, :date, :contest_index

  has_one :bracket, serializer: EventContestCategoryBracketDetailSerializer
  has_one :category, serializer: CategorySerializer

  def bracket
    EventContestCategoryBracketDetail.where(:id => object.event_bracket_id).first
  end
  def category
    Category.where(:id => object.category_id).first
  end
end
