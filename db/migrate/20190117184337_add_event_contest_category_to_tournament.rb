class AddEventContestCategoryToTournament < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :event_contest_category_id, :integer, :null => true
  end
end
