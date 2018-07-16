class CreateEventBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :event_brackets do |t|
      t.integer :event_id, :limit => 8
      t.integer :event_bracket_id, :limit => 8, :null => true
      t.float :age
      t.float :lowest_skill
      t.float :highest_skill
      t.integer :quantity, default: 0
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :event_brackets, :deleted_at
  end
end
