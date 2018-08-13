class AddCategoryToTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :category_id, :integer, :limit => 8
  end
end
