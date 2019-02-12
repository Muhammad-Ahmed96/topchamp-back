class AddContesetToTournament < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :contest_id, :integer, :limit => 8, :default => 0
  end
end
