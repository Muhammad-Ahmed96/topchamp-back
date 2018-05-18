class SponsorSerializer < ActiveModel::Serializer
  attributes :company_name, :logo, :brand, :product, :franchise_brand, :business_category, :geography, :description, :contact_name,
             :country_code, :phone, :email, :address_line_1, :address_line_2, :postal_code, :state, :city, :work_country_code,
             :work_phone, :status
end