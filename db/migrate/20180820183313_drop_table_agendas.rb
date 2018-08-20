class DropTableAgendas < ActiveRecord::Migration[5.2]
  def change
    drop_table :event_agendas
    drop_table :event_bracket_ages
    drop_table :event_bracket_skills
    drop_table :event_enrolls
    drop_table :event_enrolls_players
  end
end
