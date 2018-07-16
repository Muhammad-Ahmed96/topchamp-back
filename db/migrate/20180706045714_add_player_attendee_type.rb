class AddPlayerAttendeeType < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :attendee_type_id, :integer, :limit => 8
  end
end
