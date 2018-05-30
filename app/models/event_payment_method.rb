class EventPaymentMethod < ApplicationRecord
  include Swagger::Blocks
  validates_numericality_of :enrollment_fee, :bracket_fee
  swagger_schema :EventPaymentMethod do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :enrollment_fee do
      key :type, :float
    end
    property :bracket_fee do
      key :type, :float
    end
    property :currency do
      key :type, :string
    end
  end

  swagger_schema :EventPaymentMethodInput do
    property :enrollment_fee do
      key :type, :float
    end
    property :bracket_fee do
      key :type, :float
    end
    property :currency do
      key :type, :string
    end
  end
end
