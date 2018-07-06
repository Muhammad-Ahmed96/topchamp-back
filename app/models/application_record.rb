class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :my_order, lambda{ |column, direction = "desc"| order "#{column} #{direction}" if column.present? }
  def self.update_or_create(attributes)
    assign_or_new(attributes).save
  end

  def self.update_or_create!(attributes)
    assign_or_new(attributes).save!
  end
  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end
end
