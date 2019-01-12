class EventCalendarGroupedSerializer < ActiveModel::Serializer
  attributes :date
  has_many :schedules,  serializer: EventScheduleSerializer
  has_many :brackets,  serializer: EventBracketParentCalendarSerializer
  has_many :matches, serializer: MatchScheduleSerializer
end
