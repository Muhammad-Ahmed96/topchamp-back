class Sport < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  has_and_belongs_to_many :users
  validates :name, presence: false,  length: { maximum: 50 }

  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }

  swagger_schema :Sport do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of Sport"
    end
    property :name do
      key :type, :string
      key :description, "String of name"
    end

  end

  swagger_schema :SportInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end

  end
end
