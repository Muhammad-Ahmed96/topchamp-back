class EventContestFilterSingleSerializer < ActiveModel::Serializer
  attributes :id, :elimination_format_id, :scoring_option_match_1_id, :scoring_option_match_2_id, :sport_regulator_id,
             :has_players, :index, :has_score, :is_registration_available, :last_registration_date
  belongs_to :scoring_option_match_1, serializer: ScoringOptionSerializer
  belongs_to :scoring_option_match_2, serializer: ScoringOptionSerializer
  belongs_to :elimination_format, serializer: EliminationFormatSerializer
  belongs_to :sport_regulator, serializer: SportRegulatorSerializer
  belongs_to :venue, serializer: VenueSerializer

  def venue
    object.event.venue
  end

  def is_registration_available
    object.event.is_registration_available
  end

  def last_registration_date
    object.event.last_registration_date
  end

  has_many :categories, serializer: EventContestCategorySerializer

  def categories
    object.filter_categories
  end
end
