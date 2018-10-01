class AddEventDiscountCodeId < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :personalized_discount_code_id, :integer, :null => true
    add_column :events, :personalized_discount, :float, :null => true
  end
end
