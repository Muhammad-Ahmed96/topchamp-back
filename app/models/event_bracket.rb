class EventBracket < ApplicationRecord
  include Swagger::Blocks
  scope :only_parent, -> {where :event_bracket_id => nil}
  #scope :without_tournament, lambda {|id| joins(:tournament).merge(Tournament.where.not(:event_bracket_id => id))}
  after_destroy :on_destroy

  belongs_to :event
  has_one :tournament
  has_one :free, :class_name => "EventBracketFree"
  attr_accessor :status
  attr_accessor :user_age
  attr_accessor :user_skill
  attr_accessor :category_id

  validates :quantity,  numericality: { only_integer: true }, :allow_nil => true
  validates :lowest_skill, inclusion: {in: SkillLevels.collection},numericality:{less_than_or_equal_to: :highest_skill},  :allow_nil => true
  validates :highest_skill, inclusion: {in: SkillLevels.collection}, numericality: {greater_than_or_equal_to: :lowest_skill},  :allow_nil => true
  has_many :brackets, class_name: "EventBracket"

  scope :age_filter, lambda {|age, allow_age_range|
    if age.present?
      if allow_age_range
        where("young_age <= ?", age).where("old_age >= ?", age).or(EventBracket.where(:young_age => nil).where(:old_age => nil))
      else
        where("age <= ?", age).or(EventBracket.where(:age => nil))
      end
    end
  }
  scope :skill_filter, lambda {|skill| where("lowest_skill <= ?", skill).where("highest_skill >= ?", skill)
                                           .or(EventBracket.where(:lowest_skill => nil).where(:highest_skill => nil)) if skill.present?}
  scope :not_in, lambda {|id| where.not(:id => id) if id.present?}

  def available_for_enroll(category_id)
    result = false
    count = self.get_enroll_count category_id
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

  def get_enroll_count(category_id)
    count  = PlayerBracket.joins(:player).where(:event_bracket_id => self.id).where(:category_id => category_id).where(:enroll_status => :enroll).count
  end

  def get_free_count(category_id)
    count = self.get_enroll_count category_id
    if self.quantity.present?
      return self.quantity - count
    end
    return nil
  end

  def get_status(category_id)
    status = :waiting_list
    if self.available_for_enroll(category_id)
      status = :enroll
    elsif !self.event.registration_rule.allow_wait_list
      status = :sold_out
    end
    status
  end
  swagger_schema :EventBracket do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with bracket"
    end
    property :age do
      key :type, :number
      key :description, "Age associated with bracket"
    end
    property :young_age do
      key :type, :number
      key :description, "Young age associated with bracket"
    end
    property :old_age do
      key :type, :number
      key :description, "Old age associated with bracket"
    end
    property :lowest_skill do
      key :type, :number
      key :description, "Lowest skill associated with bracket"
    end
    property :highest_skill do
      key :type, :number
      key :description, "Highest skill associated with bracket"
    end
    property :quantity do
      key :type, :number
      key :description, "Quantity of players associated with bracket"
    end
    property :start_date do
      key :type, :string
    end
    property :time_start do
      key :type, :string
    end
    property :time_end do
      key :type, :string
    end
    property :has_players do
      key :type, :boolean
    end
    property :bracket_type do
      key :type, :string
    end
    property :contest_index do
      key :type, :integer
      key :format, :int64
      key :description, "Contest index associated with bracket"
    end
    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracketChild
      end
      key :description, "Nested brackets associated with bracket"
    end
  end

  swagger_schema :EventBracketChild do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with bracket"
    end
    property :age do
      key :type, :number
      key :description, "Age associated with bracket"
    end
    property :young_age do
      key :type, :number
      key :description, "Young age associated with bracket"
    end
    property :old_age do
      key :type, :number
      key :description, "Old age associated with bracket"
    end
    property :lowest_skill do
      key :type, :number
      key :description, "Lowest skill associated with bracket"
    end
    property :highest_skill do
      key :type, :number
      key :description, "Highest skill associated with bracket"
    end
    property :quantity do
      key :type, :number
      key :description, "Quantity of players associated with bracket"
    end
    property :start_date do
      key :type, :string
    end
    property :time_start do
      key :type, :string
    end
    property :time_end do
      key :type, :string
    end
    property :has_players do
      key :type, :boolean
    end
    property :bracket_type do
      key :type, :string
    end
    property :contest_index do
      key :type, :integer
      key :format, :int64
      key :description, "Contest index associated with bracket"
    end
  end

  swagger_schema :EventBracketInput do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :age do
      key :type, :number
    end
    property :young_age do
      key :type, :number
    end

    property :old_age do
      key :type, :number
    end
    property :lowest_skill do
      key :type, :number
    end
    property :highest_skill do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end

    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracketInputAlone
      end
    end
  end


  swagger_schema :EventBracketInputAlone do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :age do
      key :type, :number
    end

    property :young_age do
      key :type, :number
    end

    property :old_age do
      key :type, :number
    end

    property :quantity do
      key :type, :number
    end
    property :lowest_skill do
      key :type, :number
    end
    property :highest_skill do
      key :type, :number
    end
  end

  swagger_schema :EventBracketSingle do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :age do
      key :type, :number
    end
    property :young_age do
      key :type, :number
    end

    property :old_age do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end
    property :lowest_skill do
      key :type, :number
    end
    property :highest_skill do
      key :type, :number
    end
  end


  private

  def on_destroy
    PlayerBracket.where(:event_bracket_id => self.id).destroy_all
  end
end
