class CreateAgendaTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :agenda_types do |t|
      t.string :name
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :agenda_types, :deleted_at
  end
end
