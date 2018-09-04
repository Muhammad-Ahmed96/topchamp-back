class EventSchedule < ApplicationRecord
  include Swagger::Blocks

  belongs_to :event
  belongs_to :agenda_type
  belongs_to :category,  optional: true

  validates :cost, numericality: true, :allow_nil => true
  validates :capacity, numericality: {only_integer: true}, :allow_nil => true

  scope :title_like, lambda {|search| where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :category_like, lambda {|search| left_outer_joins(:category).merge(Category.where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}



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
      key :type, :string
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
    property :category do
      key :'$ref', :Category
      key :description, "Category associated with event schedule"
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

    property :venue do
      key :type, :string
      key :description, "Venue associated with event schedule"
    end
    property :category_id do
      key :type, :integer
      key :format, :int64
      key :description, "Category id associated with event schedule"
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
