class EventBracketParentCalendarSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :start_date, :time_start, :time_end
  has_many :brackets, serializer: EventContestCategoryBracketDetailSerializer
  has_one :parent_bracket, serializer: EventBracketSingleSerializer
  has_one :category, serializer: CategorySerializer
  def parent_bracket
    unless object.nil?
      EventContestCategoryBracketDetail.where(:id => object.event_contest_category_bracket_detail_id).first
    end
  end
end
