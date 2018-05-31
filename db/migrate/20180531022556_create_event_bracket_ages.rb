class CreateEventBracketAges < ActiveRecord::Migration[5.2]
  def change
    create_table :event_bracket_ages do |t|
      t.integer :event_id, :limit => 8
      t.integer :event_bracket_skill_id, :limit => 8
      t.float :youngest_age
      t.float :oldest_age
      t.integer :quantity, default: 0
      t.timestamps
    end
  end
end
