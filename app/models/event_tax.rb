class EventTax < ApplicationRecord
  include Swagger::Blocks
  validates_numericality_of :tax
  swagger_schema :EventTax do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :tax do
      key :type, :float
    end
  end
  swagger_schema :EventTaxInput do
    property :tax do
      key :type, :float
    end
  end
end
