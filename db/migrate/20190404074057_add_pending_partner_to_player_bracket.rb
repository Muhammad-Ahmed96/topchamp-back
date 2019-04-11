class AddPendingPartnerToPlayerBracket < ActiveRecord::Migration[5.2]
  def change
    add_column :player_brackets, :partner_id, :integer, :null => true
    add_column :player_brackets, :is_root, :boolean, default: false
  end
end
