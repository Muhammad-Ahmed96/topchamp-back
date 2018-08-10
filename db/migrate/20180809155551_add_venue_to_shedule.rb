class AddVenueToShedule < ActiveRecord::Migration[5.2]
  def change
    add_column :event_schedules, :venue, :string, :null => true
  end
end
