class EventPaymentInformationSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :bank_name, :bank_account
end
