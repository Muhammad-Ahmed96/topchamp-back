class AddCustomerProfileToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :customer_profile_id, :string, :null => true
  end
end
