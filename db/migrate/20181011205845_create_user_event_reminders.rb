class CreateUserEventReminders < ActiveRecord::Migration[5.2]
  def change
    create_table :user_event_reminders do |t|
      t.integer :user_id
      t.integer :event_id
      t.boolean :reminder, :default => false
      t.timestamps
    end
  end
end
