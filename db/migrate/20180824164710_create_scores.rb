class CreateScores < ActiveRecord::Migration[5.2]
  def change
    create_table :scores do |t|
      t.integer :match_set_id, :limit => 8
      t.integer :team_id, :limit => 8
      t.float :score
      t.float :time_out
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :scores, :deleted_at
  end
end
