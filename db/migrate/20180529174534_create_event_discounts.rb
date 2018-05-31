class CreateEventDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :event_discounts do |t|
      t.integer :event_id, :limit => 8, null: false
      t.float :early_bird_registration
      t.integer :early_bird_players
      t.float :late_registration
      t.integer :late_players
      t.float :on_site_registration
      t.integer :on_site_players
      t.timestamps
    end
  end
end
