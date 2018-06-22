class EditEventRegistrationRule < ActiveRecord::Migration[5.2]
  def change
    remove_column :event_registration_rules, :anyone_require_password, :boolean, default: false

    add_column :event_registration_rules, :use_link_home_page, :boolean, default: false
    add_column :event_registration_rules, :use_link_event_website, :boolean, default: false
  end
end
