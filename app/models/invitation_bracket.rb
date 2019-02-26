class InvitationBracket < ApplicationRecord
  belongs_to :bracket, class_name: "EventContestCategoryBracketDetail", :foreign_key => 'event_bracket_id'
end
