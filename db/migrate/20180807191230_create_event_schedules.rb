class CreateEventSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :event_schedules do |t|
      t.integer :event_id, :limit => 8
      t.integer :agenda_type_id, :limit => 8
      t.integer :venue_id, :limit => 8
      t.string :title, null: true
      t.string :instructor, null: true
      t.text :description, null: true
      t.date :start_date, null: true
      t.date :end_date, null: true
      t.time :start_time, null: true
      t.time :end_time, null: true
      t.float :cost
      t.integer :capacity
      t.timestamps
    end
  end
end
