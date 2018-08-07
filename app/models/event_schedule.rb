class EventSchedule < ApplicationRecord
  include Swagger::Blocks

  belongs_to :event
  belongs_to :agenda_type
  belongs_to :venue

  validates :cost, numericality: true
  validates :capacity, numericality: {only_integer: true}


  swagger_schema :EventSchedule do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with event schedule"
    end
    property :title do
      key :type, :string
      key :description, "Title associated with event schedule"
    end
    property :instructor do
      key :type, :string
      key :description, "Instructor associated with event schedule"
    end
    property :description do
      key :type, :string
      key :description, "Description associated with event schedule"
    end
    property :start_date do
      key :type, :string
      key :description, "Start date associated with event schedule\nFormat: YYYY-MM-DD"
    end
    property :end_date do
      key :type, :string
      key :description, "End date associated with event schedule\nFormat: YYYY-MM-DD"
    end
    property :start_time do
      key :type, :string
      key :description, "Start time associated with event schedule\nFormat: HH:MM"
    end
    property :end_time do
      key :type, :string
      key :description, "End time associated with event schedule\nFormat: HH:MM"
    end
    property :agenda_type do
      key :'$ref', :AgendaType
      key :description, "Agenda type associated with event schedule"
    end
    property :venue do
      key :'$ref', :Venue
      key :description, "Venue associated with event schedule"
    end

    property :cost do
      key :type, :number
      key :format, :float
      key :description, "Cost associated with event schedule"
    end

    property :capacity do
      key :type, :integer
      key :description, "Capacity associated with event schedule"
    end
  end

  swagger_schema :EventScheduleInput do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with event schedule"
    end

    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with event schedule"
    end

    property :agenda_type_id do
      key :type, :integer
      key :format, :int64
      key :description, "Agenda type id associated with event schedule"
    end

    property :venue_id do
      key :type, :integer
      key :format, :int64
      key :description, "Venue id associated with event schedule"
    end
    property :title do
      key :type, :string
      key :description, "Title associated with event schedule"
    end
    property :instructor do
      key :type, :string
      key :description, "Instructor associated with event schedule"
    end
    property :description do
      key :type, :string
      key :description, "Description associated with event schedule"
    end
    property :start_date do
      key :type, :string
      key :description, "Start date associated with event schedule\nFormat: YYYY-MM-DD"
    end
    property :end_date do
      key :type, :string
      key :description, "End date associated with event schedule\nFormat: YYYY-MM-DD"
    end
    property :start_time do
      key :type, :string
      key :description, "Start time associated with event schedule\nFormat: HH:MM"
    end
    property :end_time do
      key :type, :string
      key :description, "End time associated with event schedule\nFormat: HH:MM"
    end
    property :cost do
      key :type, :number
      key :format, :float
      key :description, "Cost associated with event schedule"
    end
    property :capacity do
      key :type, :integer
      key :description, "Capacity associated with event schedule"
    end
  end
end
