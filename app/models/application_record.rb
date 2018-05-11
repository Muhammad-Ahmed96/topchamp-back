class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.my_order(column, direction = "desc")
    if column.present?
      order "#{column} #{direction}"
    else
      self
    end
  end
end
