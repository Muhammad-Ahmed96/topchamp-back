module Payments
  class PaymentTransaction < ApplicationRecord
    attr_accessor :contests_payments
    attr_accessor :event_payments
    belongs_to :transactionable, polymorphic: true, :optional => true
    has_many :details, :class_name => 'Payments::PaymentTransactionDetail'
  end
end
