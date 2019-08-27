class AddTotalToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :total, :integer, default: 0
    add_column :payment_transaction_details, :total, :integer, default: 0
  end
end
