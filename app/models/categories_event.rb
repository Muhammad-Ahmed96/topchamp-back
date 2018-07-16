class CategoriesEvent < ApplicationRecord
  belongs_to :category
  belongs_to :event
  attr_accessor :brackets
  attr_accessor :player

  scope :only_men, lambda { joins(:category).merge(Category.where :id => Category.men_categories)}
  scope :only_women, lambda { joins(:category).merge(Category.where :id => Category.women_categories)}


  def brackets
    brackets = []
    age = player.present? ? player.user.age : nil
    #skill = player.present? ? player.skill_level.present? ? player.skill_level: -1000 : nil
    skill = player.present? ? player.skill_level: nil
     self.event.brackets.age_filter(age).skill_filter(skill).each do |bracket|
       bracket.user_age = age
       bracket.user_skill = skill
       bracket.category_id = self.category.id
       bracket.status = bracket.available_for_enroll(self.category.id)
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
