class AddAcumulativeScoreToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :general_score, :integer, :default => 0
    add_column :teams, :match_won, :integer, :default => 0
  end
end
