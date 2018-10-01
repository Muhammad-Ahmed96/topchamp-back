class CreateEventPersonalizedDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :event_personalized_discounts do |t|
      t.string :name
      t.string :email
      t.string :code
      t.float :discount
      t.integer :usage, :default => 0
      t.boolean :is_discount_percent, :default => true
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :event_personalized_discounts, :deleted_at
  end
end
