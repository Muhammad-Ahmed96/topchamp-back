class CreateInvitationBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :invitation_brackets do |t|
      t.integer :invitation_id, :limit => 8
      t.integer :event_bracket_id, :limit => 8
      t.boolean :accepted, :default => false
      t.timestamps
    end
  end
end
