class VenuePicture < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue
  has_attached_file :picture, :path => ":rails_root/public/images/venue/:to_param/:style/:basename.:extension",
                    :url => "/images/venue/:to_param/:style/:basename.:extension",
                    styles: {medium: "300X300>", thumb: "50x50>"}, default_url: "/assets/missing.png"
  #validates_attachment :picture
  #validate :check_dimensions
  #validates_with AttachmentSizeValidator, attributes: :picture, less_than: 2.megabytes
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/

  swagger_schema :VenuePicture do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :picture do
      key :type, :string
    end
  end
  private

  def check_dimensions
    required_width = 800
    required_height = 450
    temp_file = picture.queued_for_write[:original]
    unless temp_file.nil?
      dimensions = Paperclip::Geometry.from_file(temp_file.path)
      errors.add(:image, "Maximun width must be #{required_width}px") unless dimensions.width <= required_width
      errors.add(:image, "Maximun height must be #{required_height}px") unless dimensions.height <= required_height
    end
  end
end
