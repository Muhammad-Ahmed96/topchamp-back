class Participant < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  before_create :set_status
  belongs_to :user
  belongs_to :event
  has_and_belongs_to_many :attendee_types

  scope :first_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(first_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :last_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(last_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :email_like, lambda {|search| joins(:user).merge(User.where ["LOWER(email) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :status_in, lambda {|status| where status: status if status.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :event_in, lambda {|search| joins(:event).merge(Event.where id: search) if search.present?}
  scope :attendee_type_in, lambda {|search| joins(:attendee_types).merge(AttendeeType.where id: search) if search.present?}

  scope :event_order, lambda {|column, direction = "desc"| joins(:event).order("events.#{column} #{direction}") if column.present?}
  scope :user_order, lambda {|column, direction = "desc"| joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :attendee_type_order, lambda {|column, direction = "desc"| includes(:attendee_types).order("attendee_types.#{column} #{direction}") if column.present?}
  swagger_schema :Participant do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :status do
      key :type, :string
    end
    property :attendee_types do
      key :type, :array
      items do
        key :'$ref', :AttendeeType
      end
    end
    property :user do
      key :'$ref', :User
    end
    property :event do
      key :'$ref', :EventSingle
    end
  end
  private
  def set_status
    self.status = :Active
  end
end
