class TransactionsReportSerializer < ActiveModel::Serializer
  attributes :user_id, :payment_transaction_id , :player_name, :authorize_fee, :top_champ_account, :top_champ_fee, :director_receipt,
             :amount, :event_id, :available_refund, :refund_total
end
