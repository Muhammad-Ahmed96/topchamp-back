class CreateAttnedeeEnrollJoinTable < ActiveRecord::Migration[5.2]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :attendee_types, :event_enrolls do |t|
      t.index :attendee_type_id
      t.index :event_enroll_id
    end
  end
end
