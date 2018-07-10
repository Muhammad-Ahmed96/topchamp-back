class PlayerBracket < ApplicationRecord
  include Swagger::Blocks
  belongs_to :category, :optional => true
  belongs_to :bracket, :class_name => "EventBracket", :optional => true
end
