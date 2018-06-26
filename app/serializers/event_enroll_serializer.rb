class EventEnrollSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :event_id, :category_id, :event_bracket_age_id, :event_bracket_skill_id, :status

  belongs_to :user, serializer:UserSerializer
  belongs_to :event, serializer:SingleEventSerializer
  belongs_to :category, serializer:CategorySerializer
  belongs_to :bracket_skill, serializer:EventBracketSkillSerializer
  belongs_to :bracket_age, serializer:EventBracketAgeSerializer
  has_many :attendee_types, serializer: AttendeeTypeSerializer
end