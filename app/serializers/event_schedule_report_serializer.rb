class EventScheduleReportSerializer < ActiveModel::Serializer
  attributes :event_schedule_id, :event_schedule_title, :agenda_type_name,:event_schedule_capacity, :number_registrant, :capacity_registrations
end
