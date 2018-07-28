module Payments
  class PaymentTransaction < ApplicationRecord
    belongs_to :transactionable, polymorphic: true
  end
end
