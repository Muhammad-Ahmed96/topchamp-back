class AddTypeToRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :rounds, :round_type, :string, :default => 'winners'
    add_column :matches, :loser_match_a, :integer, :null => true
    add_column :matches, :loser_match_b, :integer, :null => true
  end
end
