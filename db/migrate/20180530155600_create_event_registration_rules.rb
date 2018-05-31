class CreateEventRegistrationRules < ActiveRecord::Migration[5.2]
  def change
    create_table :event_registration_rules do |t|
      t.integer :event_id, :limit => 8, null: false
      t.boolean :allow_group_registrations, default: false
      t.string :partner
      t.boolean :require_password, default: false
      t.boolean :anyone_require_password, default: false
      t.string :password
      t.boolean :require_director_approval, default: false
      t.boolean :allow_players_cancel, default: false
      t.string :link_homepage
      t.string :link_event_website
      t.boolean :use_app_event_website, default: false
      t.string :link_app
      t.timestamps
    end
  end
end
