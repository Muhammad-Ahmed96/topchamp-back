class EventCalendarDate
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Serialization

  attr_accessor :date, :schedules, :brackets, :matches

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end