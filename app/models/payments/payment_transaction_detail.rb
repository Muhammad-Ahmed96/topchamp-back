module Payments
  class PaymentTransactionDetail < ApplicationRecord
    # attr_accessor :cost
    belongs_to :payments_transaction, :class_name => 'Payments::PaymentTransaction', :optional => true
  end
end
