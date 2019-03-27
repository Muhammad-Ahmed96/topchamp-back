class Region < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  validates :base, presence: true
  validates :territory, presence: true

  scope :name_like, lambda {|search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :base_like, lambda {|search| where ["LOWER(base) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :territory_like, lambda {|search| where ["LOWER(territory) LIKE LOWER(?)", "%#{search}%"] if search.present?}

  swagger_schema :Region do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of Region"
    end
    property :name do
      key :type, :string
      key :description, "Name string"
    end
    property :base do
      key :type, :string
      key :description, "Base of region\nExample: Both, State, Country"
    end
    property :territory do
      key :type, :string
      key :description, "Description of territory"
    end
  end

  swagger_schema :RegionInput do
    key :required, [:name, :base, :territory]
    property :name do
      key :type, :string
    end
    property :base do
      key :type, :string
    end
    property :territory do
      key :type, :string
    end
  end
end
