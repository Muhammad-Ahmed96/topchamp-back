module Payments
  class PaymentTransactionDetail < ApplicationRecord
    # attr_accessor :cost
    belongs_to :bracket, :foreign_key => :event_bracket_id, :class_name => "EventContestCategoryBracketDetail", :optional => true
    belongs_to :payments_transaction, :class_name => 'Payments::PaymentTransaction', :optional => true
    def total_tax
      tax = self.tax
      if self.amount == 0 and  self.discount > 0
        tax = self.discount - self.total
      end
      tax.round(2)
    end
  end
end
