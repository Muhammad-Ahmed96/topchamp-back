class EventDiscountGeneralSerializer < ActiveModel::Serializer
  attributes :id,:event_id,  :code, :discount, :limited
end
