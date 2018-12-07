class AddRefundDataToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :for_refund, :boolean, :default => false
    add_column :payment_transactions, :is_refund, :boolean, :default => false
    add_column :payment_transactions, :refund_total, :float, :default => 0
  end
end
