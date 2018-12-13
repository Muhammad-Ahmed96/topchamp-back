class AddReferenceToRefundTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_transactions, :reference_id, :integer, :limit => 8, :nullable => true
  end
end
