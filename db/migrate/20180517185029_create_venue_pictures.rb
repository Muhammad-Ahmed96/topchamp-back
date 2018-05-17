class CreateVenuePictures < ActiveRecord::Migration[5.2]
  def change
    create_table :venue_pictures do |t|
      t.integer :venue_id, :limit => 8, null: false
      t.attachment :picture
    end
  end
end
