class RemoveEventBracket < ActiveRecord::Migration[5.2]
  def change
    drop_table :event_brackets
    drop_table :categories_events
  end
end
