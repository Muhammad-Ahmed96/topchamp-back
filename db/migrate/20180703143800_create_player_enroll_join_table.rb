class CreatePlayerEnrollJoinTable < ActiveRecord::Migration[5.2]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :players, :event_enrolls do |t|
      t.index :player_id
      t.index :event_enroll_id
    end
  end
end
