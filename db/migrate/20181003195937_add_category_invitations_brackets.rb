class AddCategoryInvitationsBrackets < ActiveRecord::Migration[5.2]
  def change
    add_column :invitation_brackets, :category_id, :integer, :null => true
  end
end
