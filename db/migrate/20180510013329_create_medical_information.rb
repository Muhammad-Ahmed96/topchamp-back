class CreateMedicalInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :medical_informations do |t|
      t.integer :user_id, :limit => 8,  null: false
      t.string :insurance_provider
      t.string :insurance_policy_number
      t.string :group_id
      t.string :primary_physician_full_name
      t.string :primary_physician_country_code_phone
      t.integer :primary_physician_phone
      t.string :dietary_restrictions
      t.string :allergies
      t.foreign_key :users, :column => :user_id, :dependent => :delete
    end
  end
end
