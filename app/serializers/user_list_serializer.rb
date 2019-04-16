class UserListSerializer < ActiveModel::Serializer
  attributes :id, :uid, :first_name, :last_name, :email, :badge_name, :birth_date, :middle_initial, :role, :profile,
             :status, :gender, :membership_id, :is_director, :age
end
