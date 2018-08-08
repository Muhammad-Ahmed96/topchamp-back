class CreatePlayersEventsSchedulesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :players, :event_schedules do |t|
      t.index :player_id
      t.index :event_schedule_id
    end
  end
end
