class CreateEventsSportsJoinTable < ActiveRecord::Migration[5.2]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :events, :sports do |t|
      t.index :event_id
      t.index :sport_id
    end
  end
end
