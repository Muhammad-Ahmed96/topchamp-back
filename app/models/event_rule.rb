class EventRule < ApplicationRecord
  include Swagger::Blocks

=begin
  belongs_to :scoring_option_match_1, foreign_key:"scoring_option_match_1_id" , class_name: "ScoringOption", optional: true
  belongs_to :scoring_option_match_2, foreign_key:"scoring_option_match_2_id" , class_name: "ScoringOption", optional: true

  validates :elimination_format, inclusion: {in: EliminationFormat.collection.keys.map(&:to_s)}
  validates :bracket_by, inclusion: {in: Bracket.collection.keys.map(&:to_s)}
=end
end
