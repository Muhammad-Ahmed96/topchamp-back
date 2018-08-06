class InvitationPartnerSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :email, :status, :status_name, :url, :sender_id
  belongs_to :event, serializer: EventSingleSerializer
  belongs_to :user, serializer: UserSingleSerializer
  has_many :attendee_types, serializer: AttendeeTypeSerializer

  def status_name
    unless object.status.nil?
      InvitationStatus.collection[object.status.to_sym]
    end
  end
end
