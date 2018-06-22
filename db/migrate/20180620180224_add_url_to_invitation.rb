class AddUrlToInvitation < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :url, :string
  end
end
