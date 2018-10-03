class CreateEventFees < ActiveRecord::Migration[5.2]
  def change
    create_table :event_fees do |t|
      t.float :base_fee
      t.float :transaction_fee
      t.boolean :is_transaction_fee_percent, :default => true
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :event_fees, :deleted_at
  end
end
