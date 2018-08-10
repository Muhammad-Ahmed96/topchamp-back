class AddSumCountToDiscountGenerals < ActiveRecord::Migration[5.2]
  def change
    add_column :event_discount_generals, :applied, :integer, :default => 0
  end
end
