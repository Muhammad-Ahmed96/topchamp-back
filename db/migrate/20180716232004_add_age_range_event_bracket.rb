class AddAgeRangeEventBracket < ActiveRecord::Migration[5.2]
  def change
    add_column :event_brackets, :young_age, :float, :null => true
    add_column :event_brackets, :old_age, :float, :null => true
  end
end
