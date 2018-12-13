class CreatePaymentTransactionDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transaction_details do |t|
      t.integer :payment_transaction_id, :limit => 8
      t.integer :event_schedule_id, :limit => 8, :null => true
      t.integer :attendee_type_id, :limit => 8, :null => true
      t.integer :event_bracket_id, :limit => 8, :null => true
      t.integer :category_id, :limit => 8, :null => true
      t.integer :event_id, :limit => 8, :null => true
      t.string :type_payment, :null => true
      t.float :amount, :default => 0
      t.float  :tax, :default => 0
      t.float  :discount, :default => 0
      t.timestamps
    end
  end
end
