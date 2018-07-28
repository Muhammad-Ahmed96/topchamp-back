class CreatePaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transactions do |t|
      t.string :transaction_id
      t.references :itemeable, polymorphic: true, index: true
      t.integer :status, :default => 1
      t.timestamps
    end
  end
end
