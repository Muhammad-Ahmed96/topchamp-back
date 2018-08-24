class Score < ApplicationRecord
  belongs_to :set, :class_name => "MatchSet", foreign_key: "match_set_id"
  belongs_to :team
end
