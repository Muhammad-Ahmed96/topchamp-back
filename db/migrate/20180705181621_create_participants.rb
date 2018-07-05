class CreateParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :participants do |t|
      t.integer :user_id, :limit => 8
      t.integer :event_id, :limit => 8
      t.string :status,  null: true
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    add_index :participants, :deleted_at
  end
end
