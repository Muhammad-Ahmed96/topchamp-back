class AddEventSheduleToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :event_schedule_id, :integer, :limit => 8, :null => true
    add_column :payment_transactions, :attendee_type_id, :integer, :limit => 8, :null => true
  end
end
