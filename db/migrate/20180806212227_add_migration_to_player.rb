class AddMigrationToPlayer < ActiveRecord::Migration[5.2]
  def change
    # add_attachment :players, :signature, :null => true
    add_column :players, :signature_file_name, :string
    add_column :players, :signature_file_size, :integer
    add_column :players, :signature_content_type, :string
    add_column :players, :signature_updated_at, :datetime
  end
end
