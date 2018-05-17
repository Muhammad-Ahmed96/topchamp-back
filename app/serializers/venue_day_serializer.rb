class VenueDaySerializer < ActiveModel::Serializer
  attributes :day, :time, :venue_id
end