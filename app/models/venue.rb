class Venue < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_many :pictures, class_name: 'VenuePicture', :dependent => :destroy
  has_one :facility_management, :dependent => :delete, class_name: 'VenueFacilityManagement'
  has_many :days, :class_name => 'VenueDay'


  validates :name, length: {maximum: 100}, presence: true
  validates :abbreviation, length: {maximum: 50}, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true, numericality: {only_integer: true}, length: {is: 10}
  #validates :sports, presence: true

  validates :description, length: {maximum: 1000}

  validates :address_line_1, presence: true
  validates :address_line_2, presence: true
  validates :postal_code, presence: true


  validates :availability_date_start, presence: true
  validates :availability_date_end, presence: true
  validate :availability_date_start_is_valid_date
  validate :availability_date_end_is_valid_datetime
  #validates :days, presence: true

  validates :restrictions, presence: true
  validates_length_of :vehicles, :minimum => 0, :maximum => 4, :allow_blank => true

  #validates :restrictions, inclusion: {in: Restrictions.collection}
  validates :facility, inclusion: {in: Facilities.collection}


  scope :is_status, lambda {|status| where status: status if status.present?}
  scope :is_facility, lambda {|facility| where facility: facility if facility.present?}
  scope :name_like, lambda {|search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :phone_number_like, lambda {|search| where ["to_char(phone_number,'9999999999') LIKE ?", "%#{search}%"] if search.present?}
  scope :state_like, lambda {|search| where ["LOWER(state) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :city_like, lambda {|search| where ["LOWER(city) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :sport_in, lambda {|search| joins(:sports).merge(Sport.where id: search) if search.present?}
  scope :facility_management_in, lambda {|search| joins(:facility_management).merge(VenueFacilityManagement.where id: search) if search.present?}
  scope :with_facility_management, lambda {|search| left_joins(:facility_management).merge(search.to_s.downcase == "yes" ? (VenueFacilityManagement.where.not id: nil) :
                                                                                               search.to_s.downcase == "no" ?  (VenueFacilityManagement.where id: nil) : self) if search.present?}

  scope :facility_management_order, lambda {|column, direction = "desc"| includes(:facility_management).order("venue_facility_managements.#{column} #{direction}") if column.present?}
  scope :sports_order, lambda {|column, direction = "desc"| includes(:sports).order("sports.#{column} #{direction}") if column.present?}


  def self.active
    where(status: :Active)
  end

  def self.inactive
    where(status: :Inactive)
  end

  def availability_date_start_is_valid_date
    errors.add(:availability_date_start, 'must be a valid datetime') if !self.availability_date_start.is_a?(Date)
  end

  def availability_date_end_is_valid_datetime
    errors.add(:availability_date_end, 'must be a valid datetime') if !self.availability_date_end.is_a?(Date)
  end

  swagger_schema :Venue do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :name do
      key :type, :string
    end

    property :abbreviation do
      key :type, :string
    end
    property :country_code do
      key :type, :string
    end
    property :phone_number do
      key :type, :string
    end
    property :link do
      key :type, :string
    end
    property :facility do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :space do
      key :type, :string
    end
    property :latitude do
      key :type, :string
    end
    property :longitude do
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
    property :city do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
    property :country do
      key :type, :string
    end
    property :availability_date_start do
      key :type, :date
    end
    property :availability_date_end do
      key :type, :date
    end
    property :availability_time_zone do
      key :type, :string
    end
    property :restrictions do
      key :type, :string
    end
    property :is_insurance_requirements do
      key :type, :boolean
    end


    property :insurance_requirements do
      key :type, :string
    end
    property :is_decorations do
      key :type, :boolean
    end
    property :decorations do
      key :type, :string
    end
    property :is_vehicles do
      key :type, :boolean
    end
    property :vehicles do
      key :type, :integer
    end
    property :status do
      key :type, :string
    end

    property :facility_management do
      key :'$ref', :VenueFacilityManagement
    end
    property :sports do
      key :type, :array
      items do
        key :'$ref', :Sport
      end
    end
    property :days do
      key :type, :array
      items do
        key :'$ref', :VenueDay
      end
    end
    property :pictures do
      key :type, :array
      items do
        key :'$ref', :VenuePicture
      end
    end

  end

  swagger_schema :VenueInput do
    key :required, [:name, :abbreviation, :country_code, :phone_number, :address_line_1, :address_line_2, :postal_code,
    :availability_date_start, :availability_date_end, :restrictions]
    property :name do
      key :type, :string
    end

    property :abbreviation do
      key :type, :string
    end
    property :country_code do
      key :type, :string
    end
    property :phone_number do
      key :type, :string
    end
    property :link do
      key :type, :string
    end
    property :facility do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :space do
      key :type, :string
    end
    property :latitude do
      key :type, :string
    end
    property :longitude do
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
    property :city do
      key :type, :string
    end
    property :state do
      key :type, :string
    end
    property :country do
      key :type, :string
    end
    property :availability_date_start do
      key :type, :date
    end
    property :availability_date_end do
      key :type, :date
    end
    property :availability_time_zone do
      key :type, :string
    end
    property :restrictions do
      key :type, :string
    end
    property :is_insurance_requirements do
      key :type, :boolean
    end


    property :insurance_requirements do
      key :type, :string
    end
    property :is_decorations do
      key :type, :boolean
    end
    property :decorations do
      key :type, :string
    end
    property :is_vehicles do
      key :type, :boolean
    end
    property :vehicles do
      key :type, :integer
    end
    property :status do
      key :type, :string
    end

  end
end
