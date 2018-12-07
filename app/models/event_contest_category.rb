class EventContestCategory < ApplicationRecord
  belongs_to :contest, :class_name => 'EventContest', :optional => true, :foreign_key => 'event_contest_id'
  has_many :brackets, :class_name => 'EventContestCategoryBracket', :dependent => :destroy
  belongs_to :category

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
    ids = EventContestCategoryBracketDetail.joins(:category)
              .merge(EventContestCategory.where(:id => self.id)).pluck(:id)
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => ids))
  end

end
