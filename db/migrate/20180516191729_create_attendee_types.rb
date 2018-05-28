class CreateAttendeeTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :attendee_types do |t|
      t.string :name
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :attendee_types, :deleted_at
  end
end
