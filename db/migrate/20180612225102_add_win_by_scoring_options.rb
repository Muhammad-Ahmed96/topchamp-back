class AddWinByScoringOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :scoring_options, :win_by, :float, null: true
  end
end
