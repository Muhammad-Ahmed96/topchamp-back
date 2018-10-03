class AddCourtToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :court, :string, :null => true
    add_column :matches, :date, :date, :null => true
    add_column :matches, :start_time, :string, :null => true
    add_column :matches, :end_time, :string, :null => true
  end
end
