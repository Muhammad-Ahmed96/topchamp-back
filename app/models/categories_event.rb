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
    not_in = player.present? ? player.brackets.where(:category_id => self.category.id).pluck(:event_bracket_id) : []
    #skill = player.present? ? player.skill_level.present? ? player.skill_level: -1000 : nil
    skill = player.present? ? player.skill_level: nil
    allow_age_range = self.event.sport_regulator.present? ? self.event.sport_regulator.allow_age_range : false
     self.event.brackets.age_filter(age, allow_age_range).skill_filter(skill).not_in(not_in).each do |bracket|
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
