class EventPaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :enrollment_fee, :bracket_fee, :currency
end
