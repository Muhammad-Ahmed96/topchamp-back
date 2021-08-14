class CreateVenuePictures < ActiveRecord::Migration[5.2]
  def change
    create_table :venue_pictures do |t|
      t.integer :venue_id, :limit => 8, null: false
      t.string :picture_file_name
      t.integer :picture_file_size
      t.string :picture_content_type
      t.datetime :picture_updated_at
    end
  end
end
