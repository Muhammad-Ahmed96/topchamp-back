class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :attendee_type_id, :email, :status, :status_name
  belongs_to :event, serializer: EventSerializer
  belongs_to :user, serializer: UserSerializer
  belongs_to :attendee_type, serializer: AttendeeTypeSerializer

  def status_name
    unless object.status.nil?
      InvitationStatus.collection[object.status.to_sym]
    end
  end
end
