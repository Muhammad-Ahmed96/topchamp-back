class CreateProcessingFees < ActiveRecord::Migration[5.2]
  def change
    create_table :processing_fees do |t|
      t.string :title
      t.float :amount_director, default: 0
      t.float :amount_registrant, default: 0
      t.boolean :is_percent, default: true
      t.timestamps
    end
  end
end
