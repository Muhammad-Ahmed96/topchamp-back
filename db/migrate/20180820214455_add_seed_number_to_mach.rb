class AddSeedNumberToMach < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :seed_team_a, :integer, :null => true
    add_column :matches, :seed_team_b, :integer, :null => true
  end
end
