class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer :venue_id, :limit => 8
      t.integer :event_type_id, :limit => 8
      t.string :title
      t.string :icon_file_name
      t.integer :icon_file_size
      t.string :icon_content_type
      t.datetime :icon_updated_at
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :visibility
      t.boolean :requires_access_code,:default => false
      t.string :event_url
      t.boolean :is_event_sanctioned, :default => false
      t.text :sanctions
      t.string :organization_name
      t.string :organization_url
      t.boolean :is_determine_later_venue, :default => false
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :events, :deleted_at
  end
end
