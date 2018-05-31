class CreateEventDiscountGenerals < ActiveRecord::Migration[5.2]
  def change
    create_table :event_discount_generals do |t|
      t.integer :event_id, :limit => 8, null: false
      t.string :code
      t.float :discount
      t.integer :limited
      t.timestamps
    end
  end
end
