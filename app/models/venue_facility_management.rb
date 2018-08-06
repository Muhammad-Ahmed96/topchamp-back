class VenueFacilityManagement < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue
  swagger_schema :VenueFacilityManagement do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of facility management"
    end
    property :primary_contact_name do
      key :type, :string
      key :description, "Primary contact name associated with facility managemen"
    end
    property :primary_contact_email do
      key :type, :string
      key :description, "Primary contact email associated with facility managemen"
    end
    property :primary_contact_country_code do
      key :type, :string
      key :description, "Primary contact country code associated with Facility managemen"
    end
    property :primary_contact_phone_number do
      key :type, :string
      key :description, "Primary contact phone number associated with facility managemen"
    end
    property :secondary_contact_name do
      key :type, :string
      key :description, "Secondary contact name associated with facility managemen"
    end
    property :secondary_contact_email do
      key :type, :string
      key :description, "Secondary contact email associated with facility managemen"
    end
    property :secondary_contact_country_code do
      key :type, :string
      key :description, "Secondary contact cluntry code associated with facility managemen"
    end
    property :secondary_contact_email do
      key :type, :string
      key :description, "Secondary contact email associated with facility managemen"
    end
    property :secondary_contact_phone_number do
      key :type, :string
      key :description, "Secondary contact phone number associated with facility managemen"
    end
  end
  swagger_schema :VenueFacilityManagementInput do
    property :primary_contact_name do
      key :type, :string
    end
    property :primary_contact_email do
      key :type, :string
    end
    property :primary_contact_country_code do
      key :type, :string
    end
    property :primary_contact_phone_number do
      key :type, :string
    end
    property :secondary_contact_name do
      key :type, :string
    end
    property :secondary_contact_email do
      key :type, :string
    end
    property :secondary_contact_country_code do
      key :type, :string
    end
    property :secondary_contact_email do
      key :type, :string
    end
    property :secondary_contact_phone_number do
      key :type, :string
    end
  end
end
