class EventType < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  def self.search(search)
    if search.present?
      where ["name LIKE ?", "%#{search}%"]
    else
      self
    end
  end
end
