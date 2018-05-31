class AddRefundPolicyToEventPaymentInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :event_payment_informations, :refund_policy, :text
    add_column :event_payment_informations, :service_fee, :float
  end
end
