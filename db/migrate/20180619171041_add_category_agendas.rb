class AddCategoryAgendas < ActiveRecord::Migration[5.2]
  def change
    add_column :event_agendas, :category_id,:integer, :limit => 8, null: true
  end
end
