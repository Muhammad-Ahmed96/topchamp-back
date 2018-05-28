class CreateContactInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_informations do |t|
      t.integer :user_id, :limit => 8, null: false
      t.string :country_code_phone
      t.string :cell_phone
      t.string :alternative_email
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :state
      t.string :city
      t.string :work_phone
      t.string :emergency_contact_full_name
      t.string :emergency_contact_country_code_phone
      t.string :emergency_contact_phone
      t.foreign_key :users, :column => :user_id, :dependent => :delete
    end
  end
end
