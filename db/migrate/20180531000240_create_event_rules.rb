class CreateEventRules < ActiveRecord::Migration[5.2]
  def change
    create_table :event_rules do |t|
      t.integer :event_id, :limit => 8, null: false
      t.string :elimination_format
      t.string :bracket_by
      t.integer :scoring_option_match_1_id, :limit => 8
      t.integer :scoring_option_match_2_id, :limit => 8
      t.timestamps
    end
  end
end
