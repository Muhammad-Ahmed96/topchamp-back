class PaymentTransactionDetailsSerializer < ActiveModel::Serializer
  attributes :id, :type_payment, :amout, :tax, :discount, :total
end
