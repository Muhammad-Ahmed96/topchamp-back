class EliminationFormat < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_one :sport, required: false

  validates :name, presence: true

  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }

  swagger_schema :EliminationFormat do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :index do
      key :type, :integer
      key :format, :int64
    end
  end

  swagger_schema :EliminationFormatInput do
    property :name do
      key :type, :string
    end
    property :index do
      key :type, :integer
      key :format, :int64
    end
  end
end
