class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :status
  has_one :event,  serializer: EventSingleSerializer
  belongs_to :user,  serializer: UserSingleSerializer
  has_many :attendee_types, serializer: AttendeeTypeSerializer


end
