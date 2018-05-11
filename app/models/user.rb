class User < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  has_and_belongs_to_many :sports
  has_one :contact_information, :dependent => :destroy
  has_one :billing_address, :dependent => :destroy
  has_one :shipping_address, :dependent => :destroy
  has_one :association_information, :dependent => :destroy
  has_one :medical_information, :dependent => :destroy

  has_attached_file :profile, :path => ":rails_root/public/images/user/:to_param/:style/:basename.:extension",
                    :url => "/images/user/:to_param/:style/:basename.:extension",
                    styles: {medium: "300x300>", thumb: "100x100>"}, default_url: "/images/:style/missing.png"
  validates_attachment :profile
  validates_with AttachmentSizeValidator, attributes: :profile, less_than: 2.megabytes
  validates_attachment_content_type :profile, content_type: /\Aimage\/.*\z/

  validates :first_name, length: {maximum: 50}, presence: true
  validates :middle_initial, length: {maximum: 1}, presence: true
  validates :last_name, length: {maximum: 50}, presence: true
  validates :badge_name, length: {maximum: 50}, presence: true
  validates :birth_date, presence: true
  validates :gender, inclusion: {in: Genders.collection}, presence: true
  validates :role, inclusion: {in: Roles.collection}, presence: true
  validates :password, presence: false
  include DeviseTokenAuth::Concerns::User

  def self.in_role(role)
    if role.present?
      where(role: role)
    else
      self
    end

  end

  def self.search(search)
    if search.present?
      where ["first_name LIKE ? OR last_name like ?", "%#{search}%", "%#{search}%"]
    else
      self
    end
  end

  def self.active
    where(status: :Active)
  end

  def self.inactive
    where(status: :Inactive)
  end
  def self.is_status(status)
    if status.present?
      where(status: status)
    else
      self
    end
  end

  def sysadmin?
    self.try(:role) == "Sysadmin"
  end

  def director?
    self.try(:role) == "Director"
  end

  def agent?
    self.try(:role) == "Agent"
  end

  def member?
    self.try(:role) == "Member"
  end

  swagger_schema :UserLogin do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :image, :badge_name]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :provider do
      key :type, :string
    end
    property :uid do
      key :type, :string
    end
    property :allow_password_change do
      key :type, :boolean
    end
    property :first_name do
      key :type, :string
    end
    property :middle_initial do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :gender do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :birth_date do
      key :type, :string
    end
    property :badge_name do
      key :type, :string
    end
    property :image do
      key :type, :string
    end
  end


  swagger_schema :User do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :image, :badge_name, :sports, :contact_information,
                    :shipping_address, :association_information, :medical_information]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :gender do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :badge_name do
      key :type, :string
    end
    property :birth_date do
      key :type, :string
    end
    property :middle_initial do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :profile do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :last_sign_in_at do
      key :type, :string
    end

    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :contact_information do
      key :'$ref', :ContactInformation
    end

    property :shipping_address do
      key :'$ref', :ShippingAddress
    end

    property :association_information do
      key :'$ref', :AssociationInformation
    end


    property :medical_information do
      key :'$ref', :MedicalInformation
    end
  end


  swagger_schema :UserInput do
    key :required, [:email, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :badge_name]

    property :first_name do
      key :type, :string
    end
    property :last_name do
      key :type, :string
    end
    property :gender do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
    property :badge_name do
      key :type, :string
    end
    property :birth_date do
      key :type, :string
    end
    property :middle_initial do
      key :type, :string
    end
    property :role do
      key :type, :string
    end
    property :profile do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :last_sign_in_at do
      key :type, :string
    end

    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :contact_information do
      key :'$ref', :ContactInformationInput
    end

    property :shipping_address do
      key :'$ref', :ShippingAddressInput
    end

    property :billing_address do
      key :'$ref', :BillingAddressInput
    end

    property :association_information do
      key :'$ref', :AssociationInformationInput
    end


    property :medical_information do
      key :'$ref', :MedicalInformationInput
    end
  end

end
