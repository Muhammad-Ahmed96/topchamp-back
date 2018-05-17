class AddIsReciveTextToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_receive_text, :boolean,default: false
  end
end
