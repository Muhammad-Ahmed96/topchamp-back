class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.integer :event_id, :limit => 8
      t.integer :event_bracket_id, :limit => 8
      t.integer :creator_user_id, :limit => 8
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
