class PlayerBracket < ApplicationRecord
  include Swagger::Blocks
  belongs_to :category, :optional => true
  belongs_to :bracket, :foreign_key => :event_bracket_id, :class_name => "EventBracket", :optional => true
  scope :enroll, -> { where enroll_status: :enroll }
  scope :wait_list, -> { where enroll_status: :waiting_list }
  swagger_schema :PlayerBracket do
    property :id do
      key :type, :integer
      key :format, :int64
    end

    property :age do
      key :type, :number
      key :format, :float
    end
    property :lowest_skill do
      key :type, :number
      key :format, :float
    end
    property :highest_skill do
      key :type, :number
      key :format, :float
    end
    property :enroll_status do
      key :type, :string
    end
    property :category do
      key :'$ref', :Category
    end

    property :parent_bracket do
      key :'$ref', :EventBracketSingle
    end


  end
  swagger_schema :PlayerBracketInput do
    property :category_id do
      key :type, :integer
      key :format, :int64
    end

    property :event_bracket_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
