class CreatePaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transactions do |t|
      t.string :payment_transaction_id
      t.references :transactionable, polymorphic: true, index: {:name => "index_transactionable"}
      t.integer :status, :default => 1
      t.integer :user_id, :limit => 8
      t.float :amount
      t.float :tax
      t.string :description
      t.timestamps
    end
  end
end
