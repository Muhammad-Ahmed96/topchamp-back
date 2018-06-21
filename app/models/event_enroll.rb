class EventEnroll < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :attendee_types, :dependent => :destroy
  belongs_to :user
  belongs_to :event
  belongs_to :category, :optional => true
  belongs_to :bracket_skill, :class_name => "EventBracketSkill", :optional => true
  belongs_to :bracket_age, :class_name => "EventBracketAge", :optional => true

  validates_presence_of :user_id, :event_id


  swagger_schema :EventEnroll do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :user_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :category_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_age_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_skill_id do
      key :type, :integer
      key :format, :integer
    end
    property :status do
      key :type, :string
    end
    property :user do
      key :'$ref', :User
    end
    property :event do
      key :'$ref', :Event
    end
    property :category do
      key :'$ref', :Category
    end
    property :bracket_skill do
      key :'$ref', :EventBracketSkill
    end
    property :bracket_age do
      key :'$ref', :EventBracketAge
    end
    property :attendee_types do
      key :type, :array
      items do
        key :'$ref', :AttendeeType
      end
    end
  end



  swagger_schema :EventEnrollInput do
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_age_id do
      key :type, :integer
      key :format, :integer
    end
    property :event_bracket_skill_id do
      key :type, :integer
      key :format, :integer
    end
  end
end
