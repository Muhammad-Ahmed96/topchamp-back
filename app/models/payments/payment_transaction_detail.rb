module Payments
  class PaymentTransactionDetail < ApplicationRecord
    belongs_to :payments_transaction, :class_name => 'Payments::PaymentTransaction', :optional => true
  end
end
