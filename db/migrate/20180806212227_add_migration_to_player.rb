class AddMigrationToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_attachment :players, :signature, :null => true
  end
end
