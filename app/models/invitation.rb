class Invitation < ApplicationRecord
  include Swagger::Blocks
  before_create :generate_token

  has_and_belongs_to_many :attendee_types
  belongs_to :event, optional: true
  belongs_to :user, optional: true
  #belongs_to :attendee_type, optional: true
  belongs_to :sender, foreign_key: "sender_id", class_name: "User", optional: true
  validates :attendee_type_id, :presence => true
  validates :url, :presence => true
  validates :email, :presence => true, email: true
  accepts_nested_attributes_for :attendee_types

  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :email_like, lambda {|search| Invitation.where ["LOWER(invitations.email) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where ["LOWER(title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :first_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(first_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :last_name_like, lambda {|search| joins(:user).merge(User.where ["LOWER(last_name) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :phone_like, lambda {|search| joins(user: :contact_information).merge(ContactInformation.where ["LOWER(concat(country_code_phone, cell_phone)) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
  scope :event_order, lambda {|column, direction = "desc"| left_joins(:event).order("events.#{column} #{direction}") if column.present?}
  scope :user_order, lambda {|column, direction = "desc"| left_joins(:user).order("users.#{column} #{direction}") if column.present?}
  scope :phone_order, lambda {|column, direction = "desc"| left_joins(user: :contact_information).order("concat(contact_informations.country_code_phone, contact_informations.#{column}) #{direction}") if column.present?}


  def self.import_invitations_xls!(file, event_id, type)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      #row = Hash[[header, spreadsheet.row(i)].transpose]
      invitaions = []
      row = spreadsheet.row(i)
      email = row[0]
      attendee_type_id = row[1]
      data = {event_id: event_id, attendee_type_id: attendee_type_id, email: email}
      senderId =  Current.user.present? ? Current.user.id : nil
      invitaions << get_invitation(data, senderId, type)
      invitaions.each {|invitation| invitation.send_mail}
    end
  end

  def self.get_invitation(params, senderId, type)
    @user = User.find_by_uid params[:email]
    userId = @user.present? ? @user.id : nil
    attendee_types = params[:attendee_types]
    if attendee_types.kind_of?(Array)
      attendee_types = attendee_types.map(&:to_i)
    end
    params.delete :attendee_types
    data = params.merge(:user_id => userId, :sender_id => senderId, :invitation_type => type)
    invitation = Invitation.where(:email => data[:email]).where(:invitation_type => type)
                     .where(:event_id => data[:event_id]).first
    if invitation.present?
      if invitation.attendee_type_ids.present? and invitation.attendee_type_ids != attendee_types
        data = data.merge(:send_at => nil)
      end
      invitation.update! data
    else
      invitation = Invitation.create!(data)
    end
    invitation.attendee_type_ids = attendee_types
    invitation
  end

  def send_mail(force = false)
    invitation = self
    if invitation.send_at.nil? or force
      case invitation.invitation_type
      when "event"
        InvitationMailer.event(invitation).deliver
      when "date"
        InvitationMailer.date(invitation).deliver
      when "sing_up"
        InvitationMailer.sing_up(invitation).deliver
      end
    end
  end

  swagger_schema :Invitation do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :attendee_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :status do
      key :type, :string
    end
    property :url do
      key :type, :string
    end
    property :attendee_types do
      key :type, :array
      items do
        key :'$ref', :AttendeeType
      end
    end
  end

  swagger_schema :InvitationInput do
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :attendee_type_id do
      key :type, :integer
      key :format, :int64
    end
    property :email do
      key :type, :string
    end
    property :url do
      key :type, :string
    end
  end
  protected
  def generate_token
    random_token = ""
    loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      other = Invitation.find_by_token(random_token)
      break if other.nil?
    end
    self.token = random_token
  end
end
