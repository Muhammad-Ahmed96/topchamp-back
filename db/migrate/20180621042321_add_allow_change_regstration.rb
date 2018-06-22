class AddAllowChangeRegstration < ActiveRecord::Migration[5.2]
  def change
    add_column :event_registration_rules, :allow_attendees_change, :boolean, default: false
  end
end
