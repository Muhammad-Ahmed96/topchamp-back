class EventSerializer < ActiveModel::Serializer
  attributes :id, :venue_id, :event_type_id, :title, :icon, :description, :start_date, :end_date, :visibility,
             :requires_access_code, :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
             :is_determine_later_venue, :access_code, :status, :creator_user_id, :valid_to_activate, :sport_regulator_id,
             :elimination_format_id, :bracket_by, :bracket, :scoring_option_match_1_id, :scoring_option_match_2_id, :sport_regulator_id,
             :awards_for, :awards_through, :awards_plus
  has_many :sports, serializer: SportSerializer
  has_many :regions, serializer: RegionSerializer
  has_many :schedules, serializer: EventScheduleSerializer
  has_many :categories, serializer: EventCategorySingleSerializer
  has_one :venue, serializer: VenueSerializer
  has_one :event_type, serializer: EventTypeSerializer
  has_one :payment_information, serializer: EventPaymentInformationSerializer
  has_one :payment_method, serializer: EventPaymentMethodSerializer

  has_one :discount, serializer: EventDiscountSerializer
  has_many :discount_generals, serializer: EventDiscountGeneralSerializer
  has_many :discount_personalizeds, serializer: EventDiscountPersonalizedSerializer
  has_one :tax, serializer: EventTaxSerializer
  has_one :registration_rule, serializer: EventRegistrationRuleSerializer
  #has_one :rule, serializer: EventRuleSerializer
  belongs_to :sport_regulator, serializer: SportRegulatorSerializer
  belongs_to :elimination_format, serializer: EliminationFormatSerializer

  has_many :brackets, serializer: EventBracketSerializer
  belongs_to :scoring_option_match_1, serializer: ScoringOptionSerializer
  belongs_to :scoring_option_match_2, serializer: ScoringOptionSerializer

  #has_many :agendas,  serializer:EventAgendaSerializer

  def valid_to_activate
    object.valid_to_activate?
  end

  def bracket
    unless object.bracket_by.nil?
      Bracket.collection[object.bracket_by.to_sym]
    end
  end

end
