class AddPartnersToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :partner_double_id, :integer, :limit => 8, :null => true
    add_column :players, :partner_mixed_id, :integer, :limit => 8, :null => true
  end
end
