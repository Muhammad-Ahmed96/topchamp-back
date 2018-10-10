class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.text :token
      t.string :platform, :nil => true
      t.timestamps
    end
  end
end
