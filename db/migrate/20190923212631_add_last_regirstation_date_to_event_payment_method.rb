class AddLastRegirstationDateToEventPaymentMethod < ActiveRecord::Migration[5.2]
  def change
    add_column :event_payment_methods, :last_registration_date, :date, :default => nil
  end
end
