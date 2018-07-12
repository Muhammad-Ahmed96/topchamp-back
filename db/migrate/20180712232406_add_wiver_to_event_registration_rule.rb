class AddWiverToEventRegistrationRule < ActiveRecord::Migration[5.2]
  def change
    add_column :event_registration_rules, :allow_waiver, :boolean, :null => true
    add_column :event_registration_rules, :waiver, :text, :null => true
    add_column :event_registration_rules, :allow_wait_list, :boolean, :null => true
  end
end
