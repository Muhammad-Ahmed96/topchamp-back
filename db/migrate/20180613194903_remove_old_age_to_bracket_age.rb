class RemoveOldAgeToBracketAge < ActiveRecord::Migration[5.2]
  def change
    rename_column :event_bracket_ages, :youngest_age, :age
    remove_column :event_bracket_ages, :oldest_age, :float
  end
end
