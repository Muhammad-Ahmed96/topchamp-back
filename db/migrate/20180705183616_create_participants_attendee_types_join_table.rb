class CreateParticipantsAttendeeTypesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :participants, :attendee_types do |t|
      t.index :participant_id
      t.index :attendee_type_id
    end
  end
end
