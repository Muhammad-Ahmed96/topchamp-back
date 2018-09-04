require 'google/apis/firebasedynamiclinks_v1'
require "erb"
include ERB::Util
class Invitation < ApplicationRecord
  include Swagger::Blocks
  before_create :generate_token

  has_and_belongs_to_many :attendee_types
  has_many :brackets, :class_name => "InvitationBracket"
  belongs_to :event, optional: true
  belongs_to :user, optional: true
  #belongs_to :attendee_type, optional: true
  belongs_to :sender, foreign_key: "sender_id", class_name: "User", optional: true
  #validates :attendee_type_id, :presence => true
  #validates :url, :presence => true
  validates :email, :presence => true, email: true
  accepts_nested_attributes_for :attendee_types

  scope :in_status, lambda {|status| where status: status if status.present?}
  scope :in_type, lambda {|type| where invitation_type: type if type.present?}
  scope :email_like, lambda {|search| Invitation.where ["LOWER(invitations.email) LIKE LOWER(?)", "%#{search}%"] if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where ["LOWER(events.title) LIKE LOWER(?)", "%#{search}%"]) if search.present?}
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
      senderId = Current.user.present? ? Current.user.id : nil
      invitaions << get_invitation(data, senderId, type)
      invitaions.each {|invitation| invitation.send_mail}
    end
  end

  def self.get_invitation(params, senderId, type)
    user = User.find_by_uid params[:email]
    userId = user.present? ? user.id : nil
    attendee_types = params[:attendee_types]
    if attendee_types.kind_of?(Array)
      attendee_types = attendee_types.map(&:to_i)
    end
    params.delete :attendee_types
    data = params.merge(:user_id => userId, :sender_id => senderId, :invitation_type => type)
=begin
    invitation = Invitation.where(:email => data[:email]).where(:invitation_type => type)
                     .where(:event_id => data[:event_id]).where(:sender_id => data[:sender_id]).first
=end
    invitation = nil
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
      when "partner_double"
        InvitationMailer.partner(invitation).deliver
      when "partner_mixed"
        InvitationMailer.partner(invitation).deliver
      end
    end
  end

  swagger_schema :Invitation do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with invitation"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with invitation"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with invitation"
    end
    property :sender_id do
      key :type, :integer
      key :format, :int64
      key :description, "Sender id associated with invitation"
    end
    property :email do
      key :type, :string
      key :description, "Email associated with invitation"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with invitation"
    end
    property :url do
      key :type, :string
      key :description, "Url associated with invitation"
    end
    property :attendee_types do
      key :type, :array
      items do
        key :'$ref', :AttendeeType
      end
      key :description, "Attendee types associated with invitation"
    end
  end

  swagger_schema :InvitationInput do
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :attendee_types do
      key :type, :array
      items do
        key :type, :integer
        key :format, :int64
      end

    end
    property :email do
      key :type, :string
    end
    property :url do
      key :type, :string
    end
  end

  def self.short_url(url)
    link = ""
    begin
      webmaster = Google::Apis::FirebasedynamiclinksV1::FirebaseDynamicLinksService.new # Alias the module
      request = Google::Apis::FirebasedynamiclinksV1::CreateShortDynamicLinkRequest.new # Alias the module
      info = Google::Apis::FirebasedynamiclinksV1::DynamicLinkInfo.new # Alias the module
      info_android = Google::Apis::FirebasedynamiclinksV1::AndroidInfo.new # Alias the module
      info_ios = Google::Apis::FirebasedynamiclinksV1::IosInfo.new # Alias the module
      info_android.android_package_name = "com.topchamp"
      info_ios.ios_bundle_id = "org.reactjs.native.example.topchamp"
      info.dynamic_link_domain = "topchamp.page.link"
      info.link = url
      #info_android. = url
      info.android_info = info_android
      info.ios_info = info_ios
      webmaster.key = "AIzaSyCDRA6uidVRErwHJqFkiV8vh4wwmKj6WyY"
      #request.long_dynamic_link = short_link
      request.dynamic_link_info = info
      response = webmaster.create_short_link_short_dynamic_link(request)
      link = response.short_link
    rescue Google::Apis::ClientError => e
      logger::info(e.to_json)
    end
    link
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
