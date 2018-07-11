class CategoriesEvent < ApplicationRecord
  belongs_to :category
  belongs_to :event

  def brackets
    brackets = []
     self.event.brackets.each do |bracket|
       if bracket.brackets.present?
         bracket.brackets.each do |child|
           child.status = child.available_for_enroll(self.category.id)
         end
       else
         bracket.status = bracket.available_for_enroll(self.category.id)
       end
       brackets << bracket
     end
    brackets
  end

  def id
    self.category.id
  end
  def name
    self.category.name
  end
end
