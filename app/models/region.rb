class Region < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  validates :base, presence: true
  validates :territoy, presence: true

  scope :name_like, lambda {|search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :base_like, lambda {|search| where ["LOWER(base) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :territoy_like, lambda {|search| where ["LOWER(territoy) LIKE LOWER(?)", "%#{search}%"] if search.present?}

  swagger_schema :Region do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
    property :base do
      key :type, :string
    end
    property :territoy do
      key :type, :string
    end
  end

  swagger_schema :RegionInput do
    key :required, [:name, :base, :territoy]
    property :name do
      key :type, :string
    end
    property :base do
      key :type, :string
    end
    property :territoy do
      key :type, :string
    end
  end
end
