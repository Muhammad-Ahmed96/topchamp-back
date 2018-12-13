class AdminReportSerializer < ActiveModel::Serializer
  attributes :event_id, :event_name, :net_income, :payment_recived, :account_balance
end
