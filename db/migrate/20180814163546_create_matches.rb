class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.integer :round_id, :limit=>8
      t.integer :team_a_id, :limit => 8, :nil => true
      t.integer :team_b_id, :limit => 8,  :nil => true
      t.integer :team_winner_id, :limit => 8,  :nil => true
      t.integer :index, :default => 0
      t.string :status, :default => "stand_by"
      t.timestamps
    end
  end
end
