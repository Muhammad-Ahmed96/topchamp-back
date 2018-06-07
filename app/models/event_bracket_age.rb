class EventBracketAge < ApplicationRecord
  include Swagger::Blocks
  validates_presence_of :oldest_age, :youngest_age
  validates :youngest_age, :inclusion => 8..100, numericality:{less_than_or_equal_to: :oldest_age}
  validates :oldest_age, :inclusion => 8..100, numericality:{greater_than_or_equal_to: :youngest_age}

  validates :youngest_age, uniqueness: { scope: :event_id }, :if => lambda{ |object| object.event_id.present? }
  validates :oldest_age, uniqueness: { scope: :event_id }, :if => lambda{ |object| object.event_id.present? }

  validates :youngest_age, uniqueness: { scope: :event_bracket_skill_id }, :if => lambda{ |object| object.event_bracket_skill_id.present? }
  validates :oldest_age, uniqueness: { scope: :event_bracket_skill_id }, :if => lambda{ |object| object.event_bracket_skill_id.present? }

  validates :quantity,  numericality: { only_integer: true }, :allow_nil => true
  has_many :bracket_skills, class_name: "EventBracketSkill", :dependent => :delete_all
  #belongs_to :bracket_skill, class_name: "EventBracketSkill"
  #
  def sync_bracket_skill!(data)
    if data.present?
      deleteIds = []
      data.each {|bracket_skill|
        if bracket_skill[:id].present?
          deleteIds << bracket_skill[:id]
        end
      }
      unless deleteIds.nil?
        self.bracket_skills.where.not(id: deleteIds).destroy_all
      end
      deleteIds = []
      data.each {|bracket_skill|
        bracket = nil
        if bracket_skill[:id].present?
          bracket = self.bracket_skills.where(id: bracket_skill[:id]).first
          if bracket.present?
            bracket.update! bracket_skill
          else
            bracket_skill[:id] = nil
            bracket = self.bracket_skills.create! bracket_skill
          end
        else
          bracket = self.bracket_skills.create! bracket_skill
        end
        deleteIds << bracket.id
      }
=begin
      unless deleteIds.nil?
        self.bracket_skills.where.not(id: deleteIds).destroy_all
      end
=end
    end
  end

  swagger_schema :EventBracketAge do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_skill_id do
      key :type, :integer
      key :format, :integer
    end
    property :youngest_age do
      key :type, :number
    end
    property :oldest_age do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end
    property :bracket_skills do
      key :type, :array
      items do
        key :'$ref', :EventBracketSkill
      end
    end
  end

  swagger_schema :EventBracketAgeInput do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :youngest_age do
      key :type, :number
    end
    property :oldest_age do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end
    property :bracket_skills do
      key :type, :array
      items do
        key :'$ref', :EventBracketSkillInputAlone
      end
    end
  end

  swagger_schema :EventBracketAgeInputAlone do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :youngest_age do
      key :type, :number
    end
    property :oldest_age do
      key :type, :number
    end
    property :quantity do
      key :type, :number
    end
  end
end
