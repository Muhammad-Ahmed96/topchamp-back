class EventSerializer < ActiveModel::Serializer
  attributes :id, :venue_id, :event_type_id, :title, :icon, :description, :start_date, :end_date, :visibility,
             :requires_access_code, :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
             :is_determine_later_venue, :access_code, :status, :creator_user_id, :valid_to_activate
  has_many :sports, serializer: SportSerializer
  has_many :regions, serializer: RegionSerializer
  has_many :categories, serializer: CategorySerializer
  has_one :venue, serializer: VenueSerializer
  has_one :event_type, serializer: EventTypeSerializer
  has_one :payment_information, serializer: EventPaymentInformationSerializer
  has_one :payment_method, serializer: EventPaymentMethodSerializer

  has_one :discount, serializer: EventDiscountSerializer
  has_many :discount_generals, serializer: EventDiscountGeneralSerializer
  has_many :discount_personalizeds, serializer: EventDiscountPersonalizedSerializer
  has_one :tax, serializer: EventTaxSerializer
  has_one :registration_rule, serializer: EventRegistrationRuleSerializer
  has_one :rule, serializer: EventRuleSerializer

  has_many :bracket_ages, serializer: EventBracketAgeSerializer
  has_many :bracket_skills, serializer: EventBracketSkillSerializer

  def valid_to_activate
    object.valid_to_activate?
  end

end
