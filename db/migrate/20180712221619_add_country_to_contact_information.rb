class AddCountryToContactInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_informations, :country, :string, :null => true
  end
end
