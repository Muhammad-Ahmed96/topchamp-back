class AddCreatedUserToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :creator_user_id, :integer, :limit => 8, null: true
    add_column :events, :invited_director_id, :integer, :limit => 8, null: true
  end
end
