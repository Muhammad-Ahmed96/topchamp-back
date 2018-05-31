class CreateCreateEventCategoriesJoinTables < ActiveRecord::Migration[5.2]
  def change
    # If you want to add an index for faster querying through this join:
    create_join_table :events, :categories do |t|
      t.index :event_id
      t.index :category_id
    end
  end
end
