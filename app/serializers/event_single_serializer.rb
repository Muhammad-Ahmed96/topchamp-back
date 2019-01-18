class EventSingleSerializer < ActiveModel::Serializer
  attributes :id, :title, :icon, :description, :start_date, :end_date, :visibility,
             :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
             :is_determine_later_venue, :access_code, :status, :creator_user_id, :reminder

  #has_many :categories, serializer: EventCategorySerializer
  #has_many :brackets, serializer: EventBracketSerializer
 # has_one :scoring_option_match_1
  #has_one :scoring_option_match_2
  #belongs_to :elimination_format, serializer: EliminationFormatSerializer
  has_many :contests, serializer: EventContestSingleSerializer
end
