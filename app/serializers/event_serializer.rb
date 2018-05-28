class EventSerializer < ActiveModel::Serializer
  attributes :id, :venue_id, :event_type_id, :title, :icon, :description, :start_date, :end_date, :visibility,
             :requires_access_code, :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
             :is_determine_later_venue
  has_many :sports, serializer: SportSerializer
  has_many :regions, serializer: RegionSerializer
  has_one :venue, serializer: VenueSerializer
  has_one :event_type, serializer: EventTypeSerializer
end
