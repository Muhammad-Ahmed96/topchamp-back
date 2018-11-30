class CreateEventContestCategoryBracketDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :event_contest_category_bracket_details do |t|
      t.integer :event_contest_category_bracket_id, :limit => 8
      t.integer :event_contest_category_bracket_detail_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.integer :event_id, :limit => 8
      t.float :age, default: 0
      t.float :lowest_skill, default: 0
      t.float :highest_skill, default: 0
      t.integer :quantity, default: 0
      t.float :young_age, default: 0
      t.float :old_age, default: 0
      t.timestamps
    end
  end
end
