class AddMatchNumberToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :match_number, :string, :null => true
  end
end
