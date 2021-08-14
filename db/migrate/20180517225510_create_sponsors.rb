class CreateSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsors do |t|
      t.string :company_name
      t.string :logo_file_name
      t.integer :logo_file_size
      t.string :logo_content_type
      t.datetime :logo_updated_at
      t.string :brand
      t.string :product
      t.string :franchise_brand
      t.string :business_category
      t.string :geography
      t.text :description
      t.string :contact_name
      t.string :country_code
      t.string :phone
      t.string :email
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :state
      t.string :city
      t.string :work_country_code
      t.string :work_phone
      t.string :status, :length => 50, default: :Active
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :sponsors, :deleted_at
  end
end
