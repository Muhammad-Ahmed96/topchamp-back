class CreateExternalUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :external_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :gender
      t.float :skill_level
      t.date :birth_date
      t.timestamps
    end
  end
end
