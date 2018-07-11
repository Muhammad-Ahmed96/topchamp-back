class AddEventBracketToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :player_brackets, :event_bracket_id,:integer,after: 'enroll_status', :limit => 8
    remove_column :player_brackets, :event_bracket_age_id,:integer, :limit => 8
    remove_column :player_brackets, :event_bracket_skill_id,:integer, :limit => 8
    remove_column :player_brackets, :string,:string
  end
end
