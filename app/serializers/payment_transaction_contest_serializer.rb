class PaymentTransactionContestSerializer < ActiveModel::Serializer
  attributes :id, :amount, :tax, :total_tax, :authorize_fee, :app_fee, :director_receipt, :account, :discount, :total,
             :created_at, :updated_at
  has_many :contests_payments, serializer: EventContestReceiptFilterSerializer
  has_many :event_payments, serializer: PaymentTransactionDetailsSerializer
end