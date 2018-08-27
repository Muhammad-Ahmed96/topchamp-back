class PlayerBracket < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  belongs_to :category, :optional => true
  belongs_to :bracket, :foreign_key => :event_bracket_id, :class_name => "EventBracket", :optional => true
  scope :enroll, -> { where enroll_status: :enroll }
  scope :wait_list, -> { where enroll_status: :waiting_list }
  scope :paid, -> { where.not payment_transaction_id: nil }
  swagger_schema :PlayerBracket do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with player bracket"
    end

    property :age do
      key :type, :number
      key :format, :float
      key :description, "Age associated with player bracket"
    end

    property :young_age do
      key :type, :number
      key :format, :float
      key :description, "Young age associated with player bracket"
    end

    property :old_age do
      key :type, :number
      key :format, :float
      key :description, "Old age associated with player bracket"
    end
    property :lowest_skill do
      key :type, :number
      key :format, :float
      key :description, "Lowest_skill associated with player bracket"
    end
    property :highest_skill do
      key :type, :number
      key :format, :float
      key :description, "Highest_skill associated with player bracket"
    end
    property :enroll_status do
      key :type, :string
      key :description, "Anroll status associated with player bracket"
    end
    property :category do
      key :'$ref', :Category
      key :description, "Category associated with player bracket"
    end

    property :parent_bracket do
      key :'$ref', :EventBracketSingle
      key :description, "Parent bracket associated with player bracket"
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
