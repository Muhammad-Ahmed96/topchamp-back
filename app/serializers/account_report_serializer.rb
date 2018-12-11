class AccountReportSerializer < ActiveModel::Serializer
  attributes :event_id, :event_name, :gross_income, :net_income, :refund, :balance
end
