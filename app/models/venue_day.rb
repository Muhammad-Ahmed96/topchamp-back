class VenueDay < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue
end
