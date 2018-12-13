class AddEventShceduleParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :event_schedules_players, :participant_id, :integer, :limit => 8, null: true
    change_column :event_schedules_players, :player_id, :integer,  :limit => 8, null: true
  end
end
