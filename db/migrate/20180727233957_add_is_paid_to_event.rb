class AddIsPaidToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_paid, :boolean, :default => false
  end
end
