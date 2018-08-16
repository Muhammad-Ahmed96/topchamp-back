class AddSoftDeletePlayerBracket < ActiveRecord::Migration[5.2]
  def change
    add_column :player_brackets, :deleted_at, :datetime, :null => true
    add_index :player_brackets, :deleted_at
  end
end
