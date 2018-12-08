class EventContestCategoryBracket < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory',:foreign_key => 'event_contest_category_id',
             :optional => true

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
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => brackets_ids))
  end

  def brackets_ids
    ids = EventContestCategoryBracketDetail.joins(:contest_bracket)
              .merge(EventContestCategoryBracket.where(:id => self.id)).pluck(:id)
    ids = ids + EventContestCategoryBracketDetail.where(:event_contest_category_bracket_detail_id => ids).pluck(:id)
    return ids
  end
end
