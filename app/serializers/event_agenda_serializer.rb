class EventAgendaSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :agenda_type_id, :category_id, :start_date, :end_date, :start_time, :end_time
  belongs_to :agenda_type
  belongs_to :category
end
