class EventRuleSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :elimination_format, :bracket_by, :scoring_option_match_1_id,
             :scoring_option_match_2_id

  belongs_to :scoring_option_match_1, serializer: ScoringOptionSerializer
  belongs_to :scoring_option_match_2, serializer: ScoringOptionSerializer
end
