class EventDiscountPersonalized < ApplicationRecord
  include Swagger::Blocks
  validates :discount, numericality: { less_than_or_equal_to: 100 }

  swagger_schema :EventDiscountPersonalized do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with discount personalized"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with discount personalized"
    end
    property :discount do
      key :type, :number
      key :format, :float
      key :description, "Discount associated with discount personalized"
    end
    property :email do
      key :type, :string
      key :description, "Email associated with discount personalized"
    end
    property :code do
      key :type, :string
      key :description, "Code associated with discount personalized"
    end
  end

  swagger_schema :EventDiscountPersonalizedInput do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :discount do
      key :type, :number
      key :format, :float
    end
    property :email do
      key :type, :string
    end
    property :code do
      key :type, :string
    end
  end
end
