class EventType < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }


  swagger_schema :EventType do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with event type"
    end
    property :name do
      key :type, :string
      key :description, "Name associated with event type"
    end
  end
end
