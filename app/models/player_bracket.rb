class PlayerBracket < ApplicationRecord
  include Swagger::Blocks
  belongs_to :category, :optional => true
  belongs_to :bracket, :foreign_key => :event_bracket_id, :class_name => "EventBracket", :optional => true


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
