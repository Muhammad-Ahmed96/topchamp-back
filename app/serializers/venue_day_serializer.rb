class VenueDaySerializer < ActiveModel::Serializer
  attributes :day, :time_start, :time_end, :venue_id
end