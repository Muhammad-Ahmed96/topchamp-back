class AddDetailsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :sport_regulator_id, :integer, :limit => 8, :null => true
    add_column :events, :elimination_format_id, :integer, :limit => 8, :null => true
    add_column :events, :bracket_by, :string, :null => true
    add_column :events, :scoring_option_match_1_id, :integer, :limit => 8, :null => true
    add_column :events, :scoring_option_match_2_id, :integer, :limit => 8, :null => true

    add_column :events, :awards_for, :string, :null => true
    add_column :events, :awards_through, :string, :null => true
    add_column :events, :awards_plus, :string, :null => true
  end
end
