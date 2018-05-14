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


  swagger_schema :EventType do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
  end
end
