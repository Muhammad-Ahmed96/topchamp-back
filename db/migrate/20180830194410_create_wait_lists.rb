class CreateWaitLists < ActiveRecord::Migration[5.2]
  def change
    create_table :wait_lists do |t|
      t.integer :event_id, :limit => 8
      t.integer :event_bracket_id, :limit => 8
      t.integer :user_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :wait_lists, :deleted_at
  end
end
