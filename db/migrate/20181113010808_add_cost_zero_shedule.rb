class AddCostZeroShedule < ActiveRecord::Migration[5.2]
  def change
    change_column :event_schedules, :cost, :float, :default => 0
  end
end
