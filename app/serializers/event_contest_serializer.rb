class EventContestSerializer < ActiveModel::Serializer
  attributes :id, :elimination_format_id, :scoring_option_match_1_id, :scoring_option_match_2_id, :sport_regulator_id,
             :has_players


  belongs_to :scoring_option_match_1, serializer: ScoringOptionSerializer
  belongs_to :scoring_option_match_2, serializer: ScoringOptionSerializer
  belongs_to :elimination_format, serializer: EliminationFormatSerializer
  belongs_to :sport_regulator, serializer: SportRegulatorSerializer
  belongs_to :venue, serializer: VenueSerializer

  has_many :categories, serializer: EventContestCategorySerializer

  def venue
    object.event.venue
  end
end
