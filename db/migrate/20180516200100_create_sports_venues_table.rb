class CreateSportsVenuesTable < ActiveRecord::Migration[5.2]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :sports, :venues do |t|
      t.index :sport_id
      t.index :venue_id
    end
  end
end
