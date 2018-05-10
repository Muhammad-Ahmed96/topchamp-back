class AddAttachmentProfileToUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :users do |t|
      t.attachment :profile
    end
  end

  def self.down
    remove_attachment :users, :profile
  end
end
