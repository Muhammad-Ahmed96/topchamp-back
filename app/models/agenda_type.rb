class AgendaType < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }
  swagger_schema :AgendaType do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with agenda type"
    end
    property :name do
      key :type, :string
      key :description, "Name associated with agenda type"
    end
  end

  swagger_schema :AgendaTypeInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end
  end
end
