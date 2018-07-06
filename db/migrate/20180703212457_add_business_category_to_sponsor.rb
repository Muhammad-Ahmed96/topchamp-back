class AddBusinessCategoryToSponsor < ActiveRecord::Migration[5.2]
  def change
    add_column :sponsors, :business_category_id, :integer, :limit => 8, null: true
    remove_column :sponsors, :business_category
  end
end
