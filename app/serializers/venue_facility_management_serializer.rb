class VenueFacilityManagementSerializer < ActiveModel::Serializer
  attributes :id,:primary_contact_name, :primary_contact_email, :primary_contact_country_code, :primary_contact_phone_number,
             :secondary_contact_name, :secondary_contact_email, :secondary_contact_country_code, :secondary_contact_phone_number
end