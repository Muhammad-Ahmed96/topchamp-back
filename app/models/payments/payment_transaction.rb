module Payments
  class PaymentTransaction < ApplicationRecord
    attr_accessor :contests_payments
    attr_accessor :event_payments
    belongs_to :transactionable, polymorphic: true, :optional => true
    has_many :details, :class_name => 'Payments::PaymentTransactionDetail'

    def total_tax
      tax = self.tax
      if self.amount == 0 and  self.discount > 0
        tax = self.discount - self.total
      end
      tax.round(2)
    end
  end
end
