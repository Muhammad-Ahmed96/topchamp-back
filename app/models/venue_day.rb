class VenueDay < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue

  swagger_schema :VenueDay do

    property :day do
      key :type, :string
    end
    property :time do
      key :type, :string
      end
    property :venue_id do
      key :type, :string
      end
  end

  swagger_schema :VenueDayInput do

    property :day do
      key :type, :string
    end
    property :time do
      key :type, :string
    end
  end
end
