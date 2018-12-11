class AddFeesToRefundTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_transactions, :app_fee, :integer, :limit => 8, :nullable => true
    add_column :refund_transactions, :authorize_fee, :integer, :limit => 8, :nullable => true
    add_column :refund_transactions, :total, :integer, :limit => 8, :nullable => true
  end
end
