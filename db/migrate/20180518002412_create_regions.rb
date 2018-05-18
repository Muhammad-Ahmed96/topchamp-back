class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.string :name
      t.string :base
      t.string :territoy
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :regions, :deleted_at
  end
end
