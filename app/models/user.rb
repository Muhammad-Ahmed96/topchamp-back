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

  scope :in_status, lambda{ |status| where status: status if status.present? }
  scope :in_role, lambda{ |role| where role: role if role.present? }
  scope :birth_date_in, lambda{ |birth_date| where birth_date: birth_date if birth_date.present? }
  scope :search, lambda{ |search| where ["first_name LIKE ? OR last_name like ?", "%#{search}%", "%#{search}%"] if search.present? }
  scope :first_name_like, lambda{ |search| where ["first_name LIKE ?", "%#{search}%"] if search.present? }
  scope :last_name_like, lambda{ |search| where ["last_name LIKE ?", "%#{search}%"] if search.present? }
  scope :gender_like, lambda{ |search| where ["gender LIKE ?", "%#{search}%"] if search.present? }
  scope :email_like, lambda{ |search| where ["email LIKE ?", "%#{search}%"] if search.present? }
  scope :last_sign_in_at_in, lambda{ |search| where last_sign_in_at:  search.beginning_of_day..search.end_of_day if search.present? }
  scope :last_sign_in_at_like, lambda{ |search| where("LOWER(to_char(last_sign_in_at, 'YYYY MONTH Day')) LIKE LOWER(?)", "%#{search}%") if search.present? }
  scope :state_like, lambda{ |search| joins(:contact_information).merge(ContactInformation.where ["state LIKE ?", "%#{search}%"] ) if search.present? }
  scope :city_like, lambda{ |search| joins(:contact_information).merge(ContactInformation.where ["city LIKE ?", "%#{search}%"] ) if search.present? }
  scope :sport_in, lambda{ |search| joins(:sports).merge(Sport.where id: search) if search.present? }
  scope :contact_information_order, lambda{ |column, direction = "desc"| includes(:contact_information).order("contact_informations.#{column} #{direction}") if column.present? }
  scope :sports_order, lambda{ |column, direction = "desc"| includes(:sports).order("sports.#{column} #{direction}") if column.present? }


  def self.active
    where(status: :Active)
  end

  def self.inactive
    where(status: :Inactive)
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
    key :required, [:id, :email, :provider, :uid, :first_name, :middle_initial,
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
  end


  swagger_schema :User do
    key :required, [:id, :email, :provider, :uid, :allow_password_change, :first_name, :middle_initial,
                    :last_name, :gender, :role, :birth_date, :profile, :badge_name, :sports, :contact_information,
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
