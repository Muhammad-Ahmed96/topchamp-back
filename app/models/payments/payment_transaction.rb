module Payments
  class PaymentTransaction < ApplicationRecord
    belongs_to :itemeable, polymorphic: true
  end
end
