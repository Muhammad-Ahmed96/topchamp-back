class AddEventToRefunds < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_transactions, :event_id, :integer, :limit => 8, :null => true
  end
end
