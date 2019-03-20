module Payments
  class PaymentTransaction < ApplicationRecord
    belongs_to :transactionable, polymorphic: true, :optional => true
    has_many :details, :class_name => 'Payments::PaymentTransactionDetail'
  end
end
