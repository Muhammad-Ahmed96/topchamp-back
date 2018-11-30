class EventContestCategoryBracket < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory', :optional => true
  has_many :brackets, class_name: "EventContestCategoryBracket"
end
