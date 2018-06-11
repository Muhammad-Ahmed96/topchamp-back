class AddUniqueIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unique_id, :string, :length => 20
  end
end
