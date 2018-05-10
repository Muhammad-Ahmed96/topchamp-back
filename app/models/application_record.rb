class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def self.my_order(column, direction = "desc")
    order "#{column} #{direction}"
  end
end
