class AddTypeToEventEnroll < ActiveRecord::Migration[5.2]
  def change
    add_column :event_enrolls, :enroll_status, :string, null: true
  end
end
