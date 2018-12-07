class EventContestCategoryBracket < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory', :optional => true
  has_many :details, class_name: "EventContestCategoryBracketDetail", :dependent => :destroy

  attr_accessor :status
  attr_accessor :user_age
  attr_accessor :user_skill
  attr_accessor :allow_age_range
  attr_accessor :ignore_brackets

  def validate_to_delete
    message = nil
    message = t('not_possible_delete') if !is_for_delete?
    return message
  end

  def is_for_delete?
    result = true
    if self.players.count > 0
      result = false
    end
    result
  end

  def players
    ids = EventContestCategoryBracketDetail.joins(:contest_bracket)
              .merge(EventContestCategoryBracket.where(:id => self.id)).pluck(:id)
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => ids))
  end
end
