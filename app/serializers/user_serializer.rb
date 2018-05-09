class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :badge_name, :birth_date, :middle_initial, :role
end
