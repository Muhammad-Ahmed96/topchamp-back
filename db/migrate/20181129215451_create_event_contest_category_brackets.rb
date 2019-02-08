class CreateEventContestCategoryBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :event_contest_category_brackets do |t|
      t.integer :event_contest_category_id, :limit => 8
      t.integer :event_contest_category_bracket_id, :limit => 8, :null => true
      t.string :bracket_type
      t.string :awards_for, :null => true
      t.string :awards_through, :null => true
      t.string :awards_plus, :null => true
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    #add_index :event_contest_category_brackets, :deleted_at
  end
end
