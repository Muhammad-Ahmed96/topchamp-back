class AddFeesToRefundTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_transactions, :app_fee, :float, :default => 0
    add_column :refund_transactions, :authorize_fee, :float, :default => 0
    add_column :refund_transactions, :total, :float, :default => 0
  end
end
