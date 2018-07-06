class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :first_name, :last_name, :email,:badge_name, :birth_date, :middle_initial, :profile,
             :status, :gender, :membership_id


=begin
             :first_name, :last_name, :email, :badge_name, :birth_date, :middle_initial, :profile,
             :status, :gender, :membership_id
=end
=begin
             :first_name, :last_name, :email,:badge_name, :birth_date, :middle_initial, :profile,
             :status, :gender, :membership_id
=end

  has_one :event,  serializer: EventSingleSerializer
  has_many :attendee_types, serializer: AttendeeTypeSerializer
  #has_many :events, serializer: EventSingleSerializer
  #has_one :event
  #
  #

=begin
  def id
    object.user.id
  end
  def first_name
    object.user.first_name
  end
  def last_name
    object.user.last_name
  end
  def email
    object.user.email
  end
  def badge_name
    object.user.badge_name
  end
  def birth_date
    object.user.birth_date
  end
  def middle_initial
    object.user.middle_initial
  end
  def profile
    object.user.profile
  end
  def status
    object.user.status
  end
  def gender
    object.user.gender
  end
  def membership_id
    object.user.membership_id
  end
=end
end
