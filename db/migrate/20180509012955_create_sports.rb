class CreateSports < ActiveRecord::Migration[5.2]
  def change
    create_table :sports do |t|
      t.string :name, :length => 50
      t.datetime :deleted_at
    end
    add_index :sports, :deleted_at
  end
end
