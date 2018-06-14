class EventAgenda < ApplicationRecord
  include Swagger::Blocks
  belongs_to :agenda_type, optional: true

  validates :event_id, presence: true
  validates :agenda_type_id, presence: true

  swagger_schema :EventAgenda do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :event_id do
      key :type, :integer
      key :format, :integer
    end
    property :agenda_type_id do
      key :type, :integer
      key :format, :integer
    end
    property :start_date do
      key :type, :string
    end
    property :end_date do
      key :type, :string
    end
    property :start_time do
      key :type, :string
    end
    property :end_time do
      key :type, :string
    end
  end

  swagger_schema :EventAgendaInput do
    property :id do
      key :type, :integer
      key :format, :integer
    end
    property :agenda_type_id do
      key :type, :integer
      key :format, :integer
    end
    property :start_date do
      key :type, :string
    end
    property :end_date do
      key :type, :string
    end
    property :start_time do
      key :type, :string
    end
    property :end_time do
      key :type, :string
    end
  end
end
