class AddTeamCounterToBreackets < ActiveRecord::Migration[5.2]
  def change
    add_column :event_contest_category_bracket_details, :team_counter, :integer, :default => 0
  end
end
