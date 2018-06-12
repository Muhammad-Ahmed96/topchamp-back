class RenameUniqueIdUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :unique_id, :membership_id
  end
end
