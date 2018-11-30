class EventContestCategoryBracketDetail < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory', :optional => true
  has_many :brackets, class_name: "EventContestCategoryBracketDetail"
end
