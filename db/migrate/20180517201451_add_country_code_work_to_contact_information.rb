class AddCountryCodeWorkToContactInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_informations, :country_code_work_phone, :string
  end
end
