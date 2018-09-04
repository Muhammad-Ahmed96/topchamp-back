class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.integer :event_id, :limit => 8, :null => true
      t.integer :user_id, :limit => 8, :null => true
      t.integer :sender_id, :limit => 8, :null => true
      t.integer :attendee_type_id, :limit => 8, :null => true
      t.string :token, :null => true
      t.string :email, :null => true
      t.datetime :send_at, :null => true
      t.string :status, default: "pending_confirmation"
      t.string :invitation_type, default: "event"
      t.timestamps
      t.datetime :deleted_at, :null => true
    end
    add_index :invitations, :deleted_at
  end
end
