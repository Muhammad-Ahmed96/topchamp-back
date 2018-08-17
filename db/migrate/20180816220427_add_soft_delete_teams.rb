class AddSoftDeleteTeams < ActiveRecord::Migration[5.2]
  def change
      add_column :teams, :deleted_at, :datetime, :null => true
      add_index :teams, :deleted_at
  end
end
