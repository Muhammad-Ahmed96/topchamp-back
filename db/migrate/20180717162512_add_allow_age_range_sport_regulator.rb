class AddAllowAgeRangeSportRegulator < ActiveRecord::Migration[5.2]
  def change
    add_column :sport_regulators, :allow_age_range, :boolean, :default => false
  end
end
