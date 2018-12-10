class AddRefundDataPaymens < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :payment_transactions, :for_refund
      add_column :payment_transactions, :for_refund, :boolean, :default => false
    end

    unless column_exists? :payment_transactions, :is_refund
      add_column :payment_transactions, :is_refund, :boolean, :default => false
    end

    unless column_exists? :payment_transactions, :refund_total
      add_column :payment_transactions, :refund_total, :float, :default => 0
    end
  end
end
