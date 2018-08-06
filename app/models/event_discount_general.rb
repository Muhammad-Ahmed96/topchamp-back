class EventDiscountGeneral < ApplicationRecord
  include Swagger::Blocks
  validates :discount, numericality: { less_than_or_equal_to: 100 }
  validates_numericality_of :limited, :only_integer => true

  swagger_schema :EventDiscountGeneral do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with discount general"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "event id associated with discount general"
    end
    property :discount do
      key :type, :number
      key :format, :float
      key :description, "Discount associated with discount general"
    end
    property :limited do
      key :type, :integer
      key :format, :int64
      key :description, "Quantity limited associated with discount general"
    end
    property :code do
      key :type, :string
      key :description, "Code associated with discount general"
    end
  end

  swagger_schema :EventDiscountGeneralInput do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :discount do
      key :type, :number
      key :format, :float
    end
    property :limited do
      key :type, :integer
      key :format, :int64
    end
    property :code do
      key :type, :string
    end
  end
end
