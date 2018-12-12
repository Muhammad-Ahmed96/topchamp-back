class AddDatestToBracket < ActiveRecord::Migration[5.2]
  def change
    add_column :event_contest_category_bracket_details, :start_date, :date, :null => true
    add_column :event_contest_category_bracket_details, :time_start, :time, :null => true
    add_column :event_contest_category_bracket_details, :time_end, :time, :null => true
  end
end
