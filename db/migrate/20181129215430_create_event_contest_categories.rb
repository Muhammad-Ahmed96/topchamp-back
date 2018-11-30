class CreateEventContestCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :event_contest_categories do |t|
      t.integer :event_contest_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.jsonb :bracket_types, :null => true
      t.timestamps
    end
  end
end
