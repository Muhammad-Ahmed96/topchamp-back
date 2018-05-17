class VenuePicture < ApplicationRecord
  include Swagger::Blocks
  belongs_to :venue
  has_attached_file :picture, :path => ":rails_root/public/images/venue/:to_param/:style/:basename.:extension",
                    :url => "/images/venue/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/images/:style/missing.png"
  validates_attachment :picture
  validates_with AttachmentSizeValidator, attributes: :picture, less_than: 2.megabytes
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\z/

  swagger_schema :VenuePicture do
    property :picture do
      key :type, :string
    end
  end
end
