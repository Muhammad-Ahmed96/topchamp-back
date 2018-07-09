class PlayerBracket < ApplicationRecord
  include Swagger::Blocks
  belongs_to :category, :optional => true
  belongs_to :bracket_skill, :foreign_key => "event_bracket_skill_id", :class_name => "EventBracketSkill", :optional => true
  belongs_to :bracket_age, :foreign_key => "event_bracket_age_id",:class_name => "EventBracketAge", :optional => true
end
