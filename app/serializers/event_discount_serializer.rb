class EventDiscountSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :early_bird_registration, :early_bird_players, :early_bird_date_start, :early_bird_date_end,
             :late_registration, :late_players, :late_date_start, :late_date_end, :on_site_registration, :on_site_players,
             :on_site_date_start, :on_site_date_end
end
