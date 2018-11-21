class Venue < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_many :pictures, class_name: 'VenuePicture', :dependent => :destroy
  has_one :facility_management, :dependent => :delete, class_name: 'VenueFacilityManagement'
  #belongs_to :availability_time_zone_obj, :foreign_key => "availability_time_zone", class_name: 'Region'
  has_many :days, :class_name => 'VenueDay'


  validates :name, length: {maximum: 100}, presence: true
  validates :abbreviation, length: {maximum: 50}, :allow_nil => true
  #validates :country_code, presence: true
  validates :phone_number, numericality: {only_integer: true}, length: {is: 10}, :allow_nil => true
  #validates :sports, presence: true

  validates :description, length: {maximum: 1000},  :allow_nil => true
  #validates :address_line_1, uniqueness: {case_sensitive: false, message: "" }


  validate do
    venue = Venue.where(:address_line_1 => self.address_line_1).where.not(:id => self.id).first
    errors.add(:address_line_1 ,"That location is already in use for venue #{venue.name}. Try another location or change your Venue name") if venue.present?
  end
  #validates :address_line_1, presence: true
  #validates :address_line_2, presence: true
  #validates :postal_code, presence: true


 # validates :availability_date_start, presence: true
  #validates :availability_date_end, presence: true
  validate :availability_date_start_is_valid_date
  validate :availability_date_end_is_valid_datetime
  #validates :days, presence: true

  #validates :restrictions, presence: true
  validates_length_of :vehicles, :minimum => 0, :maximum => 4, :allow_blank => true

  #validates :restrictions, inclusion: {in: Restrictions.collection}
  #validates :facility, inclusion: {in: Facilities.collection}


  scope :is_status, lambda {|status| where status: status if status.present?}
  scope :is_facility, lambda {|facility| where facility: facility if facility.present?}
  scope :name_like, lambda {|search| where ["LOWER(name) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :phone_number_like, lambda {|search| where ["phone_number LIKE ?","%#{search}%"] if search.present?}
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
    errors.add(:availability_date_start, 'must be a valid datetime') if self.availability_date_start.present? && !self.availability_date_start.is_a?(Date)
  end

  def availability_date_end_is_valid_datetime
    errors.add(:availability_date_end, 'must be a valid datetime') if self.availability_date_end.present? && !self.availability_date_end.is_a?(Date)
  end

  swagger_schema :Venue do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of Venue"
    end
    property :name do
      key :type, :string
      key :description, "Name string"
    end

    property :abbreviation do
      key :type, :string
      key :description, "Abbreviation of name"
    end
    property :country_code do
      key :type, :string
      key :description, "Country code associated with venue"
    end
    property :phone_number do
      key :type, :string
      key :description, "Phone number associated with venue"
    end
    property :link do
      key :type, :string
      key :description, "Url associated with venue"
    end
    property :facility do
      key :type, :string
      key :description, "Facility associated with venue"
    end
    property :description do
      key :type, :string
      key :description, "Description associated with venue"
    end
    property :space do
      key :type, :string
      key :description, "Space associated with venue"
    end
    property :latitude do
      key :type, :string
      key :description, "Latitude associated with venue"
    end
    property :longitude do
      key :type, :string
      key :description, "Longitude associated with venue"
    end
    property :address_line_1 do
      key :type, :string
      key :description, "Address line 1 associated with venue"
    end
    property :address_line_2 do
      key :type, :string
      key :description, "Address line 2 associated with venue"
    end
    property :postal_code do
      key :type, :string
      key :description, "Postal code associated with venue"
    end
    property :city do
      key :type, :string
      key :description, "City associated with venue"
    end
    property :state do
      key :type, :string
      key :description, "State associated with venue"
    end
    property :country do
      key :type, :string
      key :description, "Country associated with venue"
    end
    property :availability_date_start do
      key :type, :string
      key :format, :date
      key :description, "Availability start date associated with venue\nFormat: 'YYYY-MM-DD'"
    end
    property :availability_date_end do
      key :type, :string
      key :format, :date
      key :description, "Availability end date associated with venue\nFormat: 'YYYY-MM-DD'"
    end
    property :availability_time_zone do
      key :type, :string
      key :description, "Time zone associated with venue"
    end
    property :restrictions do
      key :type, :string
      key :description, "Restrinccions associated with venue"
    end
    property :is_insurance_requirements do
      key :type, :boolean
      key :description, "Determine insurance requirements needs"
    end
    property :insurance_requirements do
      key :type, :string
      key :description, "Insurance requirements associated with venue"
    end
    property :is_decorations do
      key :type, :boolean
      key :description, "Determine decorations requirements needs"
    end
    property :decorations do
      key :type, :string
      key :description, "Decorations associated with venue"
    end
    property :is_vehicles do
      key :type, :boolean
      key :description, "Determine vehicles requirements needs"
    end
    property :vehicles do
      key :type, :integer
      key :description, "Number of vehicles associated with venue"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with venue\nExample: Active, Inactive"
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
      key :description, "Pictures associated with venue\nExample: root_url/picture"
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
      key :type, :string
      key :format, :date
    end
    property :availability_date_end do
      key :type, :string
      key :format, :date
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
