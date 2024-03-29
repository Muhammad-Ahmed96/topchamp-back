class EventScheduleSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start_date, :end_date, :start_time, :end_time, :cost, :capacity, :instructor,
             :venue, :currency, :time_zone

  belongs_to :agenda_type, serializer: AgendaTypeSerializer
  belongs_to :category, serializer: CategorySerializer

  def start_time
    if object.start_time.present?
      return object.start_time.strftime("%H:%M")
    end
  end


  def end_time
    if object.end_time.present?
      return object.end_time.strftime("%H:%M")
    end
  end
end
