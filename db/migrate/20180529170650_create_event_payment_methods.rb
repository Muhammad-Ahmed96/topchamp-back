class CreateEventPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :event_payment_methods do |t|
      t.integer :event_id, :limit => 8, null: false
      t.float :enrollment_fee
      t.float :bracket_fee
      t.string :currency
      t.timestamps
    end
  end
end
