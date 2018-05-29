class CreateEventPaymentInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :event_payment_informations do |t|
      t.integer :event_id, :limit => 8, null: false
      t.string :bank_name
      t.string :bank_account
      t.timestamps
    end
  end
end
