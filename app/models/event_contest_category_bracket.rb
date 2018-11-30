class EventContestCategoryBracket < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory', :optional => true
  has_many :details, class_name: "EventContestCategoryBracketDetail"
end
