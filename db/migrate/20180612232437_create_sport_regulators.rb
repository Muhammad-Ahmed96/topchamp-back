class CreateSportRegulators < ActiveRecord::Migration[5.2]
  def change
    create_table :sport_regulators do |t|
      t.string :name
      t.integer :sport_id, :limit => 8, :nil => true
      t.integer :index
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :sport_regulators, :deleted_at
  end
end
