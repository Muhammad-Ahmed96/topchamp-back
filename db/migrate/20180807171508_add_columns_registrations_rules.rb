class AddColumnsRegistrationsRules < ActiveRecord::Migration[5.2]
  def change
    add_column :event_registration_rules, :is_share, :boolean, default: false
    add_column :event_registration_rules, :add_to_my_calendar, :boolean, default: false
    add_column :event_registration_rules, :enable_map, :boolean, default: false
    add_column :event_registration_rules, :share_my_cell_phone, :boolean, default: false
    add_column :event_registration_rules, :share_my_email, :boolean, default: false
    add_column :event_registration_rules, :player_cancel_start_date, :date, null: true
    add_column :event_registration_rules, :player_cancel_start_end, :date, null: true
  end
end
