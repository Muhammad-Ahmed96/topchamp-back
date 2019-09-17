class PaymentTransactionDetailsSerializer < ActiveModel::Serializer
  attributes :id, :type_payment, :amount, :tax, :discount, :total
end
