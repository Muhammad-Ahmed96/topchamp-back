class AddIsForRegisteredToInvitation < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :for_registered, :integer, :null => true
  end
end
