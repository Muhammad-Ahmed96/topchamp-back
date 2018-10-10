class AddWinnerTeamIdToTournaments < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :winner_team_id, :integer, :null => true
  end
end
