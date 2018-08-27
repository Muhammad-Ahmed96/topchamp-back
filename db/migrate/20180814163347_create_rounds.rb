class CreateRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :rounds do |t|
      t.integer :tournament_id, :limit => 8
      t.integer :index
      t.string :status, :default => "stand_by"
      t.timestamps
    end
  end
end
