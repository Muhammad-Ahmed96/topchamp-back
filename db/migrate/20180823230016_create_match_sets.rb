class CreateMatchSets < ActiveRecord::Migration[5.2]
  def change
    create_table :match_sets do |t|
      t.integer :match_id, :limit => 8
      t.integer :number
      t.string :description
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :match_sets, :deleted_at
  end
end
