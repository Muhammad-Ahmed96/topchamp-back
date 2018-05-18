class AttendeeType < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }


  swagger_schema :AttendeeType do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
  end

  swagger_schema :AttendeeTypeInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end
  end
end
