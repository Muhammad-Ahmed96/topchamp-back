class EventPaymentMethodSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :enrollment_fee, :bracket_fee, :currency
  belongs_to :processing_fee, serializer: ProcessingFeeSerializer
end
