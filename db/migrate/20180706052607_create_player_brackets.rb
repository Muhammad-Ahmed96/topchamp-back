class CreatePlayerBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :player_brackets do |t|
      t.integer :player_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.integer :event_bracket_age_id, :limit => 8
      t.integer :event_bracket_skill_id, :limit => 8
      t.string :enroll_status, :string, null: true
      t.timestamps
    end
  end
end
