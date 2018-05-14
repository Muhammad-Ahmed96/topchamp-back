class CreateAssociationInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :association_informations do |t|
      t.integer :user_id, :limit => 8, null: false
      t.string :membership_type
      t.string :membership_id
      t.string :raking
      t.string :affiliation
      t.string :certification
      t.string :company
      t.foreign_key :users, :column => :user_id, :dependent => :delete
    end
  end
end
