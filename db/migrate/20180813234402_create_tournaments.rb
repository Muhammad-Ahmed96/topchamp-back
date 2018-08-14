class CreateTournaments < ActiveRecord::Migration[5.2]
  def change
    create_table :tournaments do |t|
      t.integer :event_id, :limint => 8
      t.integer :event_bracket_id, :limint => 8
      t.integer :category_id, :limint => 8
      t.string :status, :default => "stand_by"
      t.timestamps
    end
  end
end
