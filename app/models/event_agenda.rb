class EventAgenda < ApplicationRecord
  include Swagger::Blocks
  belongs_to :agenda_type, optional: true
  belongs_to :category, optional: true

  validates :event_id, presence: true
  validates :agenda_type_id, presence: true

  swagger_schema :EventAgenda do
    property :id do
      key :type, :integer
      key :format, :integer
      key :description, "Unique identifier associated with agenda"
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
      key :description, "Event id associated with agenda"
    end
    property :agenda_type_id do
      key :type, :integer
      key :format, :integer
      key :description, "Agenda type id associated with agenda"
    end
    property :category_id do
      key :type, :integer
      key :format, :integer
      key :description, "Category id associated with agenda"
    end
    property :start_date do
      key :type, :string
      key :description, "Start date associated with agenda\nFormat: YYYY-MM-DD"
    end
    property :end_date do
      key :type, :string
      key :description, "End date associated with agenda\nFormat: YYYY-MM-DD"
    end
    property :start_time do
      key :type, :string
      key :description, "Start time associated with agenda\nFormat: HH:MM"
    end
    property :end_time do
      key :type, :string
      key :description, "End time associated with agenda\nFormat: HH:MM"
    end
    property :agenda_type do
      key :'$ref', :AgendaType
      key :description, "Agenda type associated with agenda"
    end
    property :category do
      key :'$ref', :Category
      key :description, "Category associated with agenda"
    end
  end

  swagger_schema :EventAgendaInput do
    property :id do
      key :type, :integer
      key :format, :integer
      key :description, "Unique identifier associated with agenda"
    end
    property :agenda_type_id do
      key :type, :integer
      key :format, :integer
      key :description, "Agenda type id associated with agenda"
    end
    property :category_id do
      key :type, :integer
      key :format, :integer
      key :description, "Category id associated with agenda"
    end
    property :start_date do
      key :type, :string
      key :description, "Start date associated with agenda"
    end
    property :end_date do
      key :type, :string
      key :description, "End date associated with agenda"
    end
    property :start_time do
      key :type, :string
      key :description, "Start time associated with agenda"
    end
    property :end_time do
      key :type, :string
      key :description, "End time associated with agenda"
    end
  end
end
