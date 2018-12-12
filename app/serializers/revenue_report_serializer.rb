class RevenueReportSerializer < ActiveModel::Serializer
  attributes :event_id, :event_name, :number_agenda_item, :net_revenue
end
