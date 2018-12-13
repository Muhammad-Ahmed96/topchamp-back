class AddCurrencyToEventSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :event_schedules, :currency, :string, :null => true
  end
end
