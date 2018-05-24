class AddPinToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pin, :string, :length => 50
  end
end
