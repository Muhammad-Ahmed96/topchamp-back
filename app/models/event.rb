class Event < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_and_belongs_to_many :regions
  belongs_to :venue
  belongs_to :event_type


  has_attached_file :icon, :path => ":rails_root/public/images/event_icons/:to_param/:style/:basename.:extension",
                    :url => "/images/event_icons/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/images/:style/missing.png"
  validates_attachment :icon
  validate :check_dimensions
  validates_with AttachmentSizeValidator, attributes: :icon, less_than: 2.megabytes
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  validates :title, presence: true
  validates :event_url, uniqueness: true
  validates :event_type_id, presence: true
  validates :description, length: {maximum: 1000}

  swagger_schema :Event do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :venue_id do
      key :type, :integer
      key :format, :int64
    end
    property :event_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :icon do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :start_date do
      key :type, :date
    end
    property :end_date do
      key :type, :date
    end
    property :visibility do
      key :type, :string
    end
    property :requires_access_code do
      key :type, :boolean
    end
    property :event_url do
      key :type, :string
    end
    property :is_event_sanctioned do
      key :type, :boolean
    end
    property :sanctions do
      key :type, :string
    end
    property :organization_name do
      key :type, :string
    end
    property :organization_url do
      key :type, :string
    end
    property :is_determine_later_venue do
      key :type, :boolean
    end
    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :event_type do
      items do
        key :'$ref', :EventType
      end
    end
    property :venue do
      items do
        key :'$ref', :Venue
      end
    end
    property :regions do
      key :type, :array
      items do
        key :'$ref', :Regions
      end
    end
  end
  swagger_schema :EventInput do
    key :required, [:event_type_id, :title, :description]
    property :venue_id do
      key :type, :integer
      key :format, :int64
    end
    property :event_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :icon do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :start_date do
      key :type, :date
    end
    property :end_date do
      key :type, :date
    end
    property :visibility do
      key :type, :string
    end
    property :requires_access_code do
      key :type, :boolean
    end
    property :event_url do
      key :type, :string
    end
    property :is_event_sanctioned do
      key :type, :boolean
    end
    property :sanctions do
      key :type, :string
    end
    property :organization_name do
      key :type, :string
    end
    property :organization_url do
      key :type, :string
    end
    property :is_determine_later_venue do
      key :type, :boolean
    end
    property :sports do
      key :type, :array
      items do
        key :type, :integer
        key :format, :int64
      end
    end
    property :regions do
      key :type, :array
      items do
        key :type, :integer
        key :format, :int64
      end
    end
  end
  private

  def check_dimensions
    required_width = 300
    required_height = 300
    temp_file = icon.queued_for_write[:original]
    unless temp_file.nil?
      dimensions = Paperclip::Geometry.from_file(temp_file.path)
      errors.add(:image, "Maximun width must be #{required_width}px") unless dimensions.width <= required_width
      errors.add(:image, "Maximun height must be #{required_height}px") unless dimensions.height <= required_height
    end
  end
end
