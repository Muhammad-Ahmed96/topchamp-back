class AddRefereeToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :referee, :string, :null => true
  end
end
