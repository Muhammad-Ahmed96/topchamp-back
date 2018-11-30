class EventContestCategory < ApplicationRecord
  belongs_to :contest, :class_name => 'EventContest', :optional => true
  has_many :brackets, :class_name => 'EventContestCategoryBracket'
  belongs_to :category
end
