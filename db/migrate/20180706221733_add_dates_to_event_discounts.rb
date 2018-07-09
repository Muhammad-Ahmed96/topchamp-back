class AddDatesToEventDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :event_discounts, :early_bird_date_start,:date, :null => true
    add_column :event_discounts, :early_bird_date_end, :date,:null => true
    add_column :event_discounts, :late_date_start,:date, :null => true
    add_column :event_discounts, :late_date_end, :date,:null => true
    add_column :event_discounts, :on_site_date_start,:date, :null => true
    add_column :event_discounts, :on_site_date_end, :date,:null => true
  end
end
