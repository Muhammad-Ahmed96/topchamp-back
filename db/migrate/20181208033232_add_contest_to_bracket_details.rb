class AddContestToBracketDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :event_contest_category_bracket_details, :contest_id, :integer, :limit => 8
  end
end
