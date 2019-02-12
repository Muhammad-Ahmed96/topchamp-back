class AddProcessingFeeToEventPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    add_column :event_payment_methods, :processing_fee_id, :integer, :null => true
  end
end
