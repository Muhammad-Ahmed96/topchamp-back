class AddInfoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_name, :string, :length => 50
    add_column :users, :middle_initial, :string, :length => 1
    add_column :users, :last_name, :string, :length => 50
    add_column :users, :gender, :string
    add_column :users, :role, :string
    add_column :users, :badge_name, :string, :length => 50
    add_column :users, :birth_date, :date
  end
end
