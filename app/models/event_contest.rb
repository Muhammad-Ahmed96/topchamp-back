class EventContest < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  has_many :categories, :class_name => 'EventContestCategory'

  belongs_to :scoring_option_match_1, foreign_key: "scoring_option_match_1_id", class_name: "ScoringOption", optional: true
  belongs_to :scoring_option_match_2, foreign_key: "scoring_option_match_2_id", class_name: "ScoringOption", optional: true
  belongs_to :sport_regulator, optional: true
  belongs_to :elimination_format, optional: true
end
