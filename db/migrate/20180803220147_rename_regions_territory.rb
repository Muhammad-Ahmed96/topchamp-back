class RenameRegionsTerritory < ActiveRecord::Migration[5.2]
  def change
    rename_column :regions, :territoy, :territory
  end
end
