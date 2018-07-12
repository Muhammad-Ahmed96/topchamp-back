class EventBracket < ApplicationRecord
  include Swagger::Blocks
  scope :only_parent, -> {where :event_bracket_id => nil}
  after_destroy :on_destroy

  belongs_to :event
  attr_accessor :status
  attr_accessor :user_age
  attr_accessor :user_skill
  attr_accessor :category_id

  validates :quantity,  numericality: { only_integer: true }, :allow_nil => true
  validates :lowest_skill, inclusion: {in: SkillLevels.collection},numericality:{less_than_or_equal_to: :highest_skill},  :allow_nil => true
  validates :highest_skill, inclusion: {in: SkillLevels.collection}, numericality: {greater_than_or_equal_to: :lowest_skill},  :allow_nil => true
  has_many :brackets, class_name: "EventBracket"

  scope :age_filter, lambda {|age| where("age <= ?", age).or(EventBracket.where(:age => nil)) if age.present?}
  scope :skill_filter, lambda {|skill| where("lowest_skill <= ?", skill).where("highest_skill >= ?", skill).or(EventBracket.where(:lowest_skill => nil).where(:highest_skill => nil)) if skill.present?}

  def available_for_enroll(category_id)
    count  = PlayerBracket.where(:event_bracket_id => self.id).where(:category_id => category_id).where(:enroll_status => :enroll).count
    self.quantity.nil? or self.quantity > count
  end

  def get_status(category_id)
    status = :waiting_list
    if self.available_for_enroll(category_id)
      status = :enroll
    end
    status
  end
  swagger_schema :EventBracket do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_id do
      key :type, :integer
      key :format, :integer
    end
    property :lowest_skill do
      key :type, :number
    end
    property :highest_skill do
      key :type, :number
    end
    property :age do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end
    property :status do
      key :type, :boolean
    end
    property :brackets do
      key :type, :array
      items do
        key :'$ref', :EventBracket
      end
    end
  end

  swagger_schema :EventBracketInput do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :age do
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
      key :format, :integer
    end
    property :age do
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
