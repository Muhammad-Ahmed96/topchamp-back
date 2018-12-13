class EventCalendarSerializer < ActiveModel::Serializer
 has_many :schedules,  serializer: EventScheduleSerializer
 has_many :brackets,  serializer: EventBracketParentCalendarSerializer
end
