class WaitList < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  belongs_to :user
  belongs_to :event
  belongs_to :bracket,:class_name => "EventContestCategoryBracketDetail", foreign_key: :event_bracket_id
  belongs_to :category
  swagger_schema :WaitLis do
      property :category do
      key :'$ref', :Category
      key :description, "Category associated with wait list"
    end
      property :bracket do
      key :'$ref', :EventBracket
      key :description, "bracket associated with wait list"
    end
  end

  swagger_schema :WaitListInput do
    property :category_id do
      key :in, :body
      key :required, true
      key :type, :integer
      key :format, :int64
    end
    property :event_bracket_id do
      key :in, :body
      key :required, true
      key :type, :integer
      key :format, :int64
    end
  end
end
