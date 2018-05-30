class CreateEventTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :event_taxes do |t|
      t.integer :event_id, :limit => 8, null: false
      t.string :code
      t.float :tax
      t.boolean :is_percent, default: true
      t.timestamps
    end
  end
end
