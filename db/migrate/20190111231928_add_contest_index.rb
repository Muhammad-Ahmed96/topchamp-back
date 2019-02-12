class AddContestIndex < ActiveRecord::Migration[5.2]
  def change
    add_column :event_contests, :index, :integer, :default => 0
  end
end
