class AddSlugToEliminationDormat < ActiveRecord::Migration[5.2]
  def change
    add_column :elimination_formats, :slug, :string, :null => true
  end
end
