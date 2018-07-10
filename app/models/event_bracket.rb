class EventBracket < ApplicationRecord
  include Swagger::Blocks
  scope :only_parent, -> {where :event_bracket_id => nil}

  validates :quantity,  numericality: { only_integer: true }, :allow_nil => true
  validates :lowest_skill, inclusion: {in: SkillLevels.collection},numericality:{less_than_or_equal_to: :highest_skill},  :allow_nil => true
  validates :highest_skill, inclusion: {in: SkillLevels.collection}, numericality: {greater_than_or_equal_to: :lowest_skill},  :allow_nil => true
  has_many :brackets, class_name: "EventBracket"
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
    property :available_for_enroll do
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
end
