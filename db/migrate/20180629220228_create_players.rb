class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.integer :user_id, :limit => 8
      t.integer :event_id, :limit => 8
      t.float :skill_level,  null: true
      t.string :status,  null: true
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    add_index :players, :deleted_at
  end
end
