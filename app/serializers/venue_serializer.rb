class VenueSerializer < ActiveModel::Serializer
  attributes :id,:name,:abbreviation, :country_code, :phone_number, :link, :facility, :description, :space, :latitude,
             :longitude, :address_line_1, :address_line_2, :postal_code, :city, :state, :country, :availability_date_start,
             :availability_date_end, :availability_time_zone, :restrictions, :is_insurance_requirements, :insurance_requirements,
             :is_decorations, :decorations, :is_vehicles, :vehicles
  has_many :sports
  has_many :days, serializer: VenueDaySerializer
  has_one :facility_management, serializer: VenueFacilityManagementSerializer
  has_one :pictures, serializer: VenuePictureSerializer
end