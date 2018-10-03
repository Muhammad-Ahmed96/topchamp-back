class AddIsActiveToEliminationFormats < ActiveRecord::Migration[5.2]
  def change
    add_column :elimination_formats, :is_active, :boolean, :default => true
  end
end
