class EventTaxSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :tax, :code
end
