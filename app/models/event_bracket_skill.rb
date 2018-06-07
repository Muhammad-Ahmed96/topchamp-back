class EventBracketSkill < ApplicationRecord
  include Swagger::Blocks
  validates :lowest_skill, inclusion: {in: SkillLevels.collection},numericality:{less_than_or_equal_to: :highest_skill}
  validates :highest_skill, inclusion: {in: SkillLevels.collection}, numericality: {greater_than_or_equal_to: :lowest_skill}
  validates :quantity,  numericality: { only_integer: true }, :allow_nil => true
  has_many :bracket_ages, class_name: "EventBracketAge", :dependent => :delete_all



  validates :lowest_skill, uniqueness: { scope: :event_id }, :if => lambda{ |object| object.event_id.present? }
  validates :highest_skill, uniqueness: { scope: :event_id }, :if => lambda{ |object| object.event_id.present? }

  validates :lowest_skill, uniqueness: { scope: :event_bracket_age_id }, :if => lambda{ |object| object.event_bracket_age_id.present? }
  validates :highest_skill, uniqueness: { scope: :event_bracket_age_id }, :if => lambda{ |object| object.event_bracket_age_id.present? }



  def sync_bracket_age!(data)
    if data.present?
      deleteIds = []
      data.each {|bracket_age|
        if bracket_age[:id].present?
          deleteIds << bracket_age[:id]
        end
      }
      unless deleteIds.nil?
        self.bracket_ages.where.not(id: deleteIds).destroy_all
      end
      deleteIds = []
      data.each {|bracket_age|
        bracket = nil
        if bracket_age[:id].present?
          bracket = self.bracket_ages.where(id: bracket_age[:id]).first
          if bracket.present?
            bracket.update! bracket_age
          else
            bracket_age[:id] = nil
            bracket = self.bracket_ages.create! bracket_age
          end
        else
          bracket = self.bracket_ages.create! bracket_age
        end
        deleteIds << bracket.id
      }
=begin
      unless deleteIds.nil?
        self.bracket_ages.where.not(id: deleteIds).destroy_all
      end
=end
    end
  end

  swagger_schema :EventBracketSkill do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_age_id do
      key :type, :integer
      key :format, :integer
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
    property :bracket_ages do
      key :type, :array
      items do
        key :'$ref', :EventBracketAge
      end
    end
  end

  swagger_schema :EventBracketSkillInput do
    property :id do
      key :type, :integer
      key :format, :integer
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
    property :bracket_ages do
      key :type, :array
      items do
        key :'$ref', :EventBracketAgeInputAlone
      end
    end
  end

  swagger_schema :EventBracketSkillInputAlone do
    property :id do
      key :type, :integer
      key :format, :integer
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
  end
end
