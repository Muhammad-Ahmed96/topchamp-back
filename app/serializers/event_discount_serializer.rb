class EventDiscountSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :early_bird_registration, :early_bird_players, :late_registration, :late_players,
             :on_site_registration, :on_site_players
end
