class VenueFacilityManagement < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue
  swagger_schema :VenueFacilityManagement do
    property :id do
      key :type, :integer
      key :format, :int64
    end
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
