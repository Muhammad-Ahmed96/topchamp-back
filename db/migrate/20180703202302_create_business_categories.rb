class CreateBusinessCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :business_categories do |t|
      t.string :code
      t.string :group
      t.string :description
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    add_index :business_categories, :deleted_at
  end
end
