class CreateEventAgendas < ActiveRecord::Migration[5.2]
  def change
    create_table :event_agendas do |t|
      t.integer :event_id, :limit => 8
      t.integer :agenda_type_id, :limit => 8
      t.date :start_date
      t.date :end_date
      t.string :start_time
      t.string :end_time
      t.timestamps
    end
  end
end
