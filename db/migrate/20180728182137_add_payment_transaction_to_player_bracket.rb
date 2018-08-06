class AddPaymentTransactionToPlayerBracket < ActiveRecord::Migration[5.2]
  def change
    add_column :player_brackets, :payment_transaction_id, :string, :nil => true
  end
end
