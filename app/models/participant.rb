class Participant < User
  include Swagger::Blocks
  default_scope { joins(enrolls: [:attendee_types]).where.not(attendee_types: {:id => 7}).select("users.*", "event_enrolls.id AS event_enroll_id")}

  belongs_to :enroll, foreign_key: :event_enroll_id, class_name: "EventEnroll"
  has_many :attendee_types, through: :enroll
  has_one :event, through: :enroll

  scope :event_in, lambda {|search| joins(enrolls: [:event]).merge(Event.where id: search) if search.present?}
  scope :event_like, lambda {|search| joins(enrolls: [:event]).merge(Event.where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :status_in, lambda {|search| joins(:enrolls).merge(EventEnroll.where status: search) if search.present?}
  scope :attendee_type_in, lambda {|search| joins(enrolls: [:attendee_types]).merge(AttendeeType.where id: search) if search.present?}

  scope :event_order, lambda {|column, direction = "desc"| joins(enrolls: [:event]).order("events.#{column} #{direction}") if column.present?}
  scope :attendee_type_order, lambda {|column, direction = "desc"| joins(enrolls: [:attendee_types]).order("attendee_types.#{column} #{direction}") if column.present?}
  scope :status_order, lambda {|column, direction = "desc"| joins(:enrolls).order("event_enrolls.#{column} #{direction}") if column.present?}


  def status
    self.enroll.status
  end

  def id
    self.event_enroll_id
  end


  swagger_schema :Participant do
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

    property :email do
      key :type, :string
    end
    property :status do
      key :type, :string
    end

    property :event do
      key :'$ref', :EventSingle
    end
  end
end
