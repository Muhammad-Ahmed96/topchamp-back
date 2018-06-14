class CreateEliminationFormats < ActiveRecord::Migration[5.2]
  def change
    create_table :elimination_formats do |t|
      t.string :name
      t.integer :sport_id, :limit => 8, :nil => true
      t.integer :index
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :elimination_formats, :deleted_at
  end
end
