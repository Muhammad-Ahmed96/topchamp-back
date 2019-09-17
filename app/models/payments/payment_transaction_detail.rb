module Payments
  class PaymentTransactionDetail < ApplicationRecord
    # attr_accessor :cost
    belongs_to :bracket, :foreign_key => :event_bracket_id, :class_name => "EventContestCategoryBracketDetail", :optional => true
    belongs_to :payments_transaction, :class_name => 'Payments::PaymentTransaction', :optional => true
  end
end
