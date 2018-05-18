class CreateLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :languages do |t|
      t.string :name
      t.string :locale
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :languages, :deleted_at
  end
end
