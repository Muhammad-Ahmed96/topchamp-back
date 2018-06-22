class AddEnabledToAgendaTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :agenda_types, :enabled, :boolean, default: false
  end
end
