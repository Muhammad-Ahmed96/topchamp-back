class CreateVenueDays < ActiveRecord::Migration[5.2]
  def change
    create_table :venue_days do |t|
      t.integer :venue_id, :limit => 8, null: false
      t.string :day
      t.string :time
      t.timestamps
    end
  end
end
