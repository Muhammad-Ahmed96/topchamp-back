class Event < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_and_belongs_to_many :regions
  belongs_to :venue
  belongs_to :event_type
  has_one :payment_information,    class_name: 'EventPaymentInformation'
  has_one :payment_method,   class_name: 'EventPaymentMethod'
  has_one :discount,   class_name: 'EventDiscount'
  has_many :discount_generals, class_name: 'EventDiscountGeneral'
  has_many :discount_personalizeds, class_name: 'EventDiscountPersonalized'
  has_one :tax, class_name: 'EventTax'

  accepts_nested_attributes_for :discount_generals
  accepts_nested_attributes_for :discount_personalizeds


  has_attached_file :icon, :path => ":rails_root/public/images/event_icons/:to_param/:style/:basename.:extension",
                    :url => "/images/event_icons/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/assets/missing.png"
  validates_attachment :icon
  validate :check_dimensions
  validates_with AttachmentSizeValidator, attributes: :icon, less_than: 2.megabytes
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  validates :title, presence: true
  validates :event_url, uniqueness: true
  validates :event_type_id, presence: true
  validates :description, length: {maximum: 1000}

  def sync_discount_generals!(data)
    if data.present?
      deleteIds = []
      discounts_general = nil
      data.each {|discount|
        if discount[:id].present?
          discounts_general = self.discount_generals.where(id: discount[:id]).first
          if discounts_general.present?
            discounts_general.update! discount
          else
            discount[:id] = nil
            discounts_general = self.discount_generals.create! discount
          end
        else
          discounts_general = self.discount_generals.create! discount
        end
        deleteIds << discounts_general.id
      }
      unless discounts_general.nil?
        self.discount_generals.where.not(id: deleteIds).destroy_all
      end
    end
  end

  def sync_discount_personalizeds!(data)
    if data.present?
      deleteIds = []
      discount_personalized = nil
      data.each {|discount|
        if discount[:id].present?
          discount_personalized = self.discount_personalizeds.where(id: discount[:id]).first
          if discount_personalized.present?
            discount_personalized.update! discount
          else
            discount[:id] = nil
            discount_personalized = self.discount_personalizeds.create! discount
          end
        else
          discount_personalized = self.discount_personalizeds.create! discount
        end
        deleteIds << discount_personalized.id
      }
      unless discount_personalized.nil?
        self.discount_personalizeds.where.not(id: deleteIds).destroy_all
      end
    end
  end

  def import_discount_personalizeds!(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
     #row = Hash[[header, spreadsheet.row(i)].transpose]
      row = spreadsheet.row(i)
      email = row[0]
      code = row[1]
      discount = row[2]
      saved = self.discount_personalizeds.where(email: email).where(code: code).first
      if saved.present?
        saved.update!({discount: discount})
      else
        self.discount_personalizeds.create!({email: email, code: code, discount: discount})
      end
    end
  end

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
