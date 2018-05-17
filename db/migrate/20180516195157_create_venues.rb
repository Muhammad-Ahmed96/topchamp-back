class CreateVenues < ActiveRecord::Migration[5.2]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :abbreviation
      t.string :country_code
      t.integer :phone_number
      t.string :link
      t.string :facility


      t.text :description
      t.string :space

      t.text :latitude
      t.text :longitude
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :city
      t.string :state
      t.string :country

      t.date :availability_date_start
      t.date :availability_date_end
      t.string :availability_time_zone

      t.string :restrictions
      t.boolean :is_insurance_requirements
      t.text :insurance_requirements
      t.boolean :is_decorations
      t.text :decorations
      t.boolean :is_vehicles
      t.integer :vehicles
      t.string :status, :length => 50, default: :Active
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :venues, :deleted_at
  end
end
