class CreateEventTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :event_types do |t|
      t.string :name
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :event_types, :deleted_at
  end
end
