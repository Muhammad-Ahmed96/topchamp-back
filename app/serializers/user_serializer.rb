class UserSerializer < ActiveModel::Serializer
  attributes :id, :uid, :first_name, :last_name, :email, :badge_name, :birth_date, :middle_initial, :role, :profile,
             :status, :last_sign_in_at, :gender, :is_receive_text
  has_many :sports
  has_one :contact_information
  has_one :billing_address
  has_one :shipping_address
  has_one :association_information
  has_one :medical_information
end
