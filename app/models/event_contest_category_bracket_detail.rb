class EventContestCategoryBracketDetail < ApplicationRecord
  belongs_to :category,:optional => true
  belongs_to :event,  :optional => true
  belongs_to :contest, class_name: 'EventContest', :optional => true
  belongs_to :contest_bracket, class_name: 'EventContestCategoryBracket', :foreign_key => 'event_contest_category_bracket_id',
             :optional => true
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
  scope :start_date_between, lambda {|start_date, end_date| where("start_date >= ? AND start_date <= ?", start_date, end_date ) if start_date.present? and end_date.present?}


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

  def has_players
    !self.is_for_delete?
  end

  def players
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => brackets_ids))
  end

  def brackets_ids
    ids = [self.id]
    ids = ids + EventContestCategoryBracketDetail.where(:event_contest_category_bracket_detail_id => ids).pluck(:id)
    return ids
  end

  def status
    return self.get_status
  end

  def available_for_enroll
    result = false
    count = self.get_enroll_count
    if self.quantity.nil? && self.event_contest_category_bracket_detail_id.nil?
      result = true
      return result
    end
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


  def send_free_mail
    event = self.event
    if self.event.registration_rule.present? and self.event.registration_rule.allow_wait_list
      free_spaces = self.get_free_count
      if free_spaces.present? and free_spaces > 0

        url = Rails.configuration.front_new_spot_url.gsub "{event_id}", event.id.to_s
        url = url.gsub "{event_bracket_id}", self.id.to_s
        url = url.gsub "{category_id}", self.category_id.to_s
        url = Invitation.short_url url
        users = User.joins(:wait_lists).merge(WaitList.where(:event_bracket_id => self.id)
                                                  .where(:event_id => event.id)).all
        users.each do |user|
          UnsubscribeMailer.spot_open(user, event, url).deliver
        end
        EventBracketFree.where(:event_bracket_id => self.id)
            .update_or_create!({:event_bracket_id => self.id, :category_id => self.category_id, :free_at => DateTime.now,
                                :url => url})
      end
    end
  end
  def bracket_type
    unless self.contest_bracket.nil?
      self.contest_bracket.bracket_type
    end
  end

  def contest_index
    self.contest.index
  end
end
