class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :my_order, lambda{ |column, direction = "desc"| order "#{column} #{direction}" if column.present? }
end
