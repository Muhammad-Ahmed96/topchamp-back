class CreateRefundTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_transactions do |t|
      t.string :payment_transaction_id
      t.float :amount
      t.string :type_refund
      t.string :card_number, :null => true
      t.string :expiration_date, :null => true

      t.string :routing_number, :null => true
      t.string :account_number, :null => true
      t.string :name_on_account, :null => true
      t.string :bank_name, :null => true
      t.string :account_type, :null => true
      t.string :e_check_type, :null => true
      t.string :check_number, :null => true

      t.integer :from_user_id, :limit => 8
      t.integer :to_user_id, :limit => 8
      t.string  :status, :default => 'pending'
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :refund_transactions, :deleted_at
  end
end
