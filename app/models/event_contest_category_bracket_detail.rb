class EventContestCategoryBracketDetail < ApplicationRecord
  belongs_to :category, :class_name => 'EventContestCategory', :optional => true
  belongs_to :event,  :optional => true
  belongs_to :contest_bracket, class_name: 'EventContestCategoryBracket',  :optional => true
  has_many :brackets, class_name: "EventContestCategoryBracketDetail", :dependent => :destroy
  attr_accessor :status
  attr_accessor :user_age
  attr_accessor :user_skill
  attr_accessor :allow_age_range
  attr_accessor :bracket_type
  attr_accessor :ignore_brackets

  scope :age_filter, lambda {|age, allow_age_range|
    if age.present?
      if allow_age_range
        where("young_age <= ?", age).where("old_age >= ?", age).or(EventContestCategoryBracketDetail.where(:young_age => nil).where(:old_age => nil))
      else
        where("age <= ?", age).or(EventContestCategoryBracketDetail.where(:age => nil))
      end
    end
  }

  scope :skill_filter, lambda {|skill| where("lowest_skill <= ?", skill).where("highest_skill >= ?", skill).or(EventContestCategoryBracketDetail.where(:lowest_skill => nil).where(:highest_skill => nil)) if skill.present?}
  scope :not_in, lambda {|id| where.not(:id => id) if id.present?}


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
    ids = [self.id]
    ids << self.event_contest_category_bracket_id if self.event_contest_category_bracket_id.present?
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => ids))
  end

  def status
    return self.get_status
  end

  def available_for_enroll
    result = false
    count = self.get_enroll_count
    category_id = self.category_id
    free = EventBracketFree.where(:event_bracket_id => self.id).where(:category_id => category_id).first
    hours = nil
    in_wait_list = 0
    if free.present?
      hours = TimeDifference.between(Time.current, free.free_at).in_hours
      in_wait_list = WaitList.where(:user_id => Current.user.id).where(:category_id => category_id)
                         .where(:event_bracket_id => self.id).where(:event_id => self.event_id).where("created_at <= ?", free.free_at).count
      general_wait_list = WaitList.where(:category_id => category_id)
                              .where(:event_bracket_id => self.id).where(:event_id => self.event_id).where("created_at <= ?", free.free_at).count
    end
    if general_wait_list == 0
      in_wait_list = 1
    end
    if self.quantity.present? and (self.quantity > count and (hours.nil? or (hours > Rails.configuration.hours_bracket or in_wait_list > 0)))
      result = true
    end
    return result
  end


  def get_enroll_count
    count  = PlayerBracket.joins(:player).where(:event_bracket_id => self.id).where(:category_id => self.category_id).where(:enroll_status => :enroll).count
  end

  def get_free_count
    count = self.get_enroll_count
    if self.quantity.present?
      return self.quantity - count
    end
    return nil
  end

  def get_status
    status = :waiting_list
    if self.available_for_enroll
      status = :enroll
    elsif !self.event.registration_rule.allow_wait_list
      status = :sold_out
    end
    status
  end
end
