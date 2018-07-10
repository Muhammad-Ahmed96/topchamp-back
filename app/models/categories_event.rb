class CategoriesEvent < ApplicationRecord
  belongs_to :category
  belongs_to :event

  def brackets
   self.event.brackets
  end

  def id
    self.category.id
  end
  def name
    self.category.name
  end
end
