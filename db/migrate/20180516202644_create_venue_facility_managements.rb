class CreateVenueFacilityManagements < ActiveRecord::Migration[5.2]
  def change
    create_table :venue_facility_managements do |t|
      t.integer :venue_id, :limit => 8, null: false
      t.string :primary_contact_name
      t.string :primary_contact_email
      t.string :primary_contact_country_code
      t.string :primary_contact_phone_number
      t.string :secondary_contact_name
      t.string :secondary_contact_email
      t.string :secondary_contact_country_code
      t.string :secondary_contact_phone_number

      t.timestamps
    end
  end
end
