class AddExtraDataToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :event_bracket_id, :integer, :limit => 8, :null => true
    add_column :payment_transactions, :category_id, :integer, :limit => 8, :null => true
    add_column :payment_transactions, :event_id, :integer, :limit => 8, :null => true
    add_column :payment_transactions, :type_payment, :string, :null => true
  end
end
