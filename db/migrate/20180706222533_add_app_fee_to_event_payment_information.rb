class AddAppFeeToEventPaymentInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :event_payment_informations, :app_fee, :float, :null => true
  end
end
