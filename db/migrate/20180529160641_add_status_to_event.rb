class AddStatusToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :status, :string, :length => 50, default: :Inactive
  end
end
