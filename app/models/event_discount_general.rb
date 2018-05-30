class EventDiscountGeneral < ApplicationRecord
  include Swagger::Blocks
  validates :discount, numericality: { less_than_or_equal_to: 100 }
  validates_numericality_of :limited, :only_integer => true

  swagger_schema :EventDiscountGeneral do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :discount do
      key :type, :float
    end
    property :limited do
      key :type, :int64
    end
    property :code do
      key :type, :string
    end
  end

  swagger_schema :EventDiscountGeneralInput do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :discount do
      key :type, :float
    end
    property :limited do
      key :type, :int64
    end
    property :code do
      key :type, :string
    end
  end
end
