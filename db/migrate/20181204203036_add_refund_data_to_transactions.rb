class AddRefundDataToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :for_refund, :boolean, :default => false
    add_column :payment_transactions, :is_refund, :boolean, :default => false
    add_column :payment_transactions, :refund_total, :float, :default => 0
    add_column :payment_transactions, :contest_id, :integer, :limit => 8, :null => true
    add_column :payment_transaction_details, :contest_id, :integer, :limit => 8, :null => true
  end
end
