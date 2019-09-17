class PaymentTransactionSerializer < ActiveModel::Serializer
  attributes :id, :amount, :tax, :authorize_fee, :app_fee, :director_receipt, :account, :discount, :total,
             :created_at, :updated_at
  has_many :details, serializer: PaymentTransactionDetailsSerializer
end
