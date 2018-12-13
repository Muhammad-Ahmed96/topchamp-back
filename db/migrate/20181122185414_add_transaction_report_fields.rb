class AddTransactionReportFields < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_transactions, :authorize_fee, :float, default: 0
    add_column :payment_transactions, :app_fee, :float, default: 0
    add_column :payment_transactions, :director_receipt, :float, default: 0
    add_column :payment_transactions, :account, :float, default: 0
    add_column :payment_transactions, :discount, :float, default: 0

    remove_columns :payment_transactions, :event_bracket_id, :category_id, :event_schedule_id, :attendee_type_id, :type_payment
  end
end
