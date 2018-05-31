class CreateScoringOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :scoring_options do |t|
      t.string :description
      t.integer :quantity_games
      t.integer :winner_games
      t.float :points
      t.float :duration
      t.integer :index
      t.timestamps
    end
  end
end
