class CreateEventBracketSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :event_bracket_skills do |t|
      t.integer :event_id, :limit => 8
      t.integer :event_bracket_age_id, :limit => 8
      t.float :lowest_skill
      t.float :highest_skill
      t.integer :quantity, default: 0
      t.timestamps
    end
  end
end
