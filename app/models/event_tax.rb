class EventTax < ApplicationRecord
  include Swagger::Blocks
  validates_numericality_of :tax
  swagger_schema :EventTax do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with tax"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with tax"
    end
    property :tax do
      key :type, :number
      key :format, :float
      key :description, "Tax associated with tax"
    end
    property :code do
      key :type, :string
      key :description, "Code associated with tax"
    end
  end
  swagger_schema :EventTaxInput do
    property :tax do
      key :type, :number
      key :format, :float
    end
    property :code do
      key :type, :string
    end
  end
end
