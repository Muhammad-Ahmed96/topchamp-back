class CreateShippingAddress < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_addresses do |t|
      t.integer :user_id, :limit => 8, null: false
      t.string :contact_name
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :city
      t.string :state
      t.foreign_key :users, :column => :user_id, :dependent => :delete
    end
  end
end
