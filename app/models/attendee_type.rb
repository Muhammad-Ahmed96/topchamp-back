class AttendeeType < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :name, presence: true
  scope :search, lambda{ |search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present? }


  def self.player_id
    type = self.where(:name => "Player").first
    player_type = 0
    unless type.nil?
      player_type = type.id
    end
    player_type
  end

  def self.director_id
    type = self.where(:name => "Director").first
    player_type = 0
    unless type.nil?
      player_type = type.id
    end
    player_type
  end

  swagger_schema :AttendeeType do
    key :required, [:id, :name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end
  end

  swagger_schema :AttendeeTypeInput do
    key :required, [:name]
    property :name do
      key :type, :string
    end
  end
end
