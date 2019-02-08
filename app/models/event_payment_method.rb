class EventPaymentMethod < ApplicationRecord
  include Swagger::Blocks
  belongs_to :processing_fee, :optional => true
  validates_numericality_of :enrollment_fee, :bracket_fee
  swagger_schema :EventPaymentMethod do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with payment method"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with payment method"
    end
    property :enrollment_fee do
      key :type, :number
      key :format, :float
      key :description, "Enrollment fee associated with payment method"
    end
    property :bracket_fee do
      key :type, :number
      key :format, :float
      key :description, "Bracket fee associated with payment method"
    end
    property :currency do
      key :type, :string
      key :description, "Currency associated with payment method"
    end
  end

  swagger_schema :EventPaymentMethodInput do
    property :enrollment_fee do
      key :type, :number
      key :format, :float
    end
    property :bracket_fee do
      key :type, :number
      key :format, :float
    end
    property :currency do
      key :type, :string
    end
  end
end
