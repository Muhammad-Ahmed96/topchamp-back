class AddMatchesProgressToTournament < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :matches_status, :string, :default => "not_complete"
    add_column :tournaments, :teams_count, :integer, :default => 0
  end
end
