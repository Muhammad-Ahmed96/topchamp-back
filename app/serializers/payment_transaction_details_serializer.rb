class PaymentTransactionDetailsSerializer < ActiveModel::Serializer
  attributes :id, :type_payment, :amount, :tax, :total_tax, :discount, :total
end
