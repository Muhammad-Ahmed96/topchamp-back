class CreateEventEnrolls < ActiveRecord::Migration[5.2]
  def change
    create_table :event_enrolls do |t|
      t.integer :user_id, :limit => 8
      t.integer :event_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.integer :event_bracket_age_id, :limit => 8
      t.integer :event_bracket_skill_id, :limit => 8
      t.string :status
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    add_index :event_enrolls, :deleted_at
  end
end
