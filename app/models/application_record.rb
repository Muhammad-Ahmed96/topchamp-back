class ApplicationRecord < ActiveRecord::Base
  delegate :t, to: I18n
  self.abstract_class = true

  scope :my_order, lambda{ |column, direction = "desc"| order "#{column} #{direction}" if column.present? }
  def self.update_or_create(attributes)
    obj = assign_or_new(attributes)
    obj.save
    obj
  end

  def self.update_or_create!(attributes)
    obj = assign_or_new(attributes)
    obj.save!
    obj
  end
  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end
end
