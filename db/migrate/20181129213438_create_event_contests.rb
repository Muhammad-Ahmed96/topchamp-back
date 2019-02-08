class CreateEventContests < ActiveRecord::Migration[5.2]
  def change
    create_table :event_contests do |t|
      t.integer :event_id, :limit => 8
      t.integer :elimination_format_id, :limit => 8, :null => true
      t.integer :scoring_option_match_1_id, :limit => 8
      t.integer :scoring_option_match_2_id, :limit => 8
      t.integer :sport_regulator_id, :limit => 8
      t.timestamps
    end
  end
end
