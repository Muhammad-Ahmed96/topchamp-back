class AddTimeRangeToVenueTimes < ActiveRecord::Migration[5.2]
  def change
    add_column :venue_days, :time_start, :time
    add_column :venue_days, :time_end, :time
    remove_column :venue_days, :time
  end
end
