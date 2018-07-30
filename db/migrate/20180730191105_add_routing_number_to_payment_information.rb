class AddRoutingNumberToPaymentInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :event_payment_informations, :bank_routing_number, :string, :nil => true
  end
end
