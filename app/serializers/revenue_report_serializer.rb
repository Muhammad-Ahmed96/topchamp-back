class RevenueReportSerializer < ActiveModel::Serializer
  attributes :event_id, :event_name, :revenue, :number_agenda_item, :payment_recived, :subtotal
end
