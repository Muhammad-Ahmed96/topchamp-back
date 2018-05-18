class AddStatusToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :status, :string, :length => 50, default: :Active
  end
end