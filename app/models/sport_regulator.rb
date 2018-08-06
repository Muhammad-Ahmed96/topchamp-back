class SportRegulator < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_one :sport, required: false

  validates :name, presence: true

  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }

  swagger_schema :SportRegulator do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with sport regulator"
    end
    property :name do
      key :type, :string
      key :description, "Name associated with sport regulator"
    end
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index associated with sport regulator"
    end
  end

  swagger_schema :SportRegulatorInput do
    property :name do
      key :type, :string
    end
    property :index do
      key :type, :integer
      key :format, :int64
    end
  end
end
