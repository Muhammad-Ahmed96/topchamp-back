class VenueDay < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue

  swagger_schema :VenueDay do

    property :day do
      key :type, :string
      key :description, "Day name"
    end
    property :time_start do
      key :type, :string
      key :description, "Time start associated with day"
    end
    property :time_end do
      key :type, :string
      key :description, "Time end associated with day"
    end
    property :venue_id do
      key :type, :string
      end
  end

  swagger_schema :VenueDayInput do

    property :day do
      key :type, :string
    end
    property :time_start do
      key :type, :string
    end
    property :time_end do
      key :type, :string
    end
  end
end
