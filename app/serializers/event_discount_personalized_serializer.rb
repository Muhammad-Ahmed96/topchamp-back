class EventDiscountPersonalizedSerializer < ActiveModel::Serializer
  attributes :id,:event_id, :email, :code, :discount
end
