class Venue < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid

  has_and_belongs_to_many :sports
  has_many :pictures, class_name: 'VenuePicture', :dependent => :destroy
  has_one :facility_management, :dependent => :delete,  class_name: 'VenueFacilityManagement'
  has_many :days, :class_name => 'VenueDay'


  validates :name, length: {maximum: 100}, presence: true
  validates :abbreviation, length: {maximum: 50}, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true, numericality: { only_integer: true },  length: { is: 10 }
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

  validates :restrictions, inclusion: {in: Restrictions.collection}
  validates :facility, inclusion: {in: Facilities.collection}


  scope :is_status, lambda {|status| where status: status if status.present?}


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
end
