class AddTimeZoneToEventSchedule < ActiveRecord::Migration[5.2]
  def change
    add_column :event_schedules, :time_zone, :string, :null => true
    change_column :event_schedules, :cost, :float, :default => 0
  end
end
