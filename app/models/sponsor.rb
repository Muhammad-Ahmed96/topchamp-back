class Sponsor < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  validates :company_name, presence: true
 # validates :brand, presence: true
  validates :product, presence: true
 # validates :franchise_brand, presence: true
  validates :business_category, presence: true
  validates :geography, presence: true
  validates :geography, inclusion: {in: Geography.collection}

  belongs_to :business_category


  has_attached_file :logo, :path => ":rails_root/public/images/sponsor/:to_param/:style/:basename.:extension",
                    :url => "/images/sponsor/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/assets/missing.png"
  validates_attachment :logo
  validates_with AttachmentSizeValidator, attributes: :logo, less_than: 2.megabytes
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/

  validates :contact_name, presence: true
  validates :country_code, presence: true
  validates :phone, presence: true, numericality: {only_integer: true}, length: {is: 10}

  validates :work_country_code, presence: true
  validates :work_phone, presence: true, numericality: {only_integer: true}, length: {is: 10}


  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :in_geography, lambda {|geography| where geography: geography if geography.present?}
  scope :company_name_like, lambda {|search| where ["LOWER(company_name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :brand_like, lambda {|search| where ["LOWER(brand) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :product_like, lambda {|search| where ["LOWER(product) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :franchise_brand_like, lambda {|search| where ["LOWER(franchise_brand) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :business_category_like, lambda {|search| where ["LOWER(business_category) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :city_like, lambda {|search| where ["LOWER(city) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :state_like, lambda {|search| where ["LOWER(state) LIKE LOWER(?)", "%#{search}%"] if search.present?}

  def self.active
    where(status: :Active)
  end

  def self.inactive
    where(status: :Inactive)
  end

  swagger_schema :Sponsor do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with sponsor"
    end
    property :company_name do
      key :type, :string
      key :description, "Company name associated with sponsor"
    end

    property :logo do
      key :type, :string
      key :description, "Logo associated with sponsor"
    end

    property :product do
      key :type, :string
      key :description, "Product associated with sponsor"
    end
    property :franchise_brand do
      key :type, :string
      key :description, "Franchise brand associated with sponsor"
    end
    property :business_category_id do
      key :type, :string
      key :description, "Business category id associated with sponsor"
    end
    property :geography do
      key :type, :string
      key :description, "Geography associated with sponsor"
    end
    property :description do
      key :type, :string
      key :description, "Description associated with sponsor"
    end
    property :contact_name do
      key :type, :string
      key :description, "Contact name associated with sponsor"
    end
    property :country_code do
      key :type, :string
      key :description, "Country code associated with sponsor"
    end
    property :phone do
      key :type, :integer
      key :description, "Phone associated with sponsor"
    end
    property :email do
      key :type, :string
      key :description, "Email associated with sponsor"
    end
    property :address_line_1 do
      key :type, :string
      key :description, "Address line 1 associated with sponsor"
    end
    property :address_line_2 do
      key :type, :string
      key :description, "Address line 2 associated with sponsor"
    end
    property :postal_code do
      key :type, :string
      key :description, "Postal code associated with sponsor"
    end
    property :state do
      key :type, :string
      key :description, "State associated with sponsor"
    end
    property :city do
      key :type, :string
      key :description, "City associated with sponsor"
    end
    property :work_country_code do
      key :type, :string
      key :description, "Work country code associated with sponsor"
    end
    property :work_phone do
      key :type, :integer
      key :description, "Work phone associated with sponsor"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with sponsor"
    end

    property :business_category do
      key :'$ref', :BusinessCategory
      key :description, "Business category associated with sponsor"
    end
  end

  swagger_schema :SponsorInput do
    key :required, [:company_name, :product, :franchise_brand, :business_category, :geography, :contact_name, :country_code,
    :phone, :work_country_code, :work_phone]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :company_name do
      key :type, :string
    end

    property :logo do
      key :type, :string
    end
    property :product do
      key :type, :string
    end
    property :franchise_brand do
      key :type, :string
    end
    property :business_category_id do
      key :type, :string
    end
    property :geography do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :contact_name do
      key :type, :string
    end
    property :country_code do
      key :type, :string
    end
    property :phone do
      key :type, :integer
    end
    property :email do
      key :type, :string
    end
    property :address_line_1 do
      key :type, :string
    end
    property :address_line_2 do
      key :type, :string
    end
    property :postal_code do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
    property :city do
      key :type, :string
    end
    property :work_country_code do
      key :type, :string
    end
    property :work_phone do
      key :type, :integer
    end
  end
end
