class CreateEventBracketFrees < ActiveRecord::Migration[5.2]
  def change
    create_table :event_bracket_frees do |t|
      t.integer :event_bracket_id, :limit => 8
      t.integer :category_id, :limit => 8
      t.datetime :free_at
      t.string :url
      t.timestamps
    end
  end
end
