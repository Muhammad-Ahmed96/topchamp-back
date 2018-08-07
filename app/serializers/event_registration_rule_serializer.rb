class EventRegistrationRuleSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :allow_group_registrations, :partner, :require_password, :password,
             :require_director_approval, :allow_players_cancel, :use_link_home_page, :link_homepage,:use_link_event_website,
             :link_event_website, :allow_attendees_change, :allow_waiver, :waiver, :allow_wait_list, :is_share, :add_to_my_calendar,
             :enable_map, :share_my_cell_phone, :share_my_email, :player_cancel_start_date, :player_cancel_start_end

end
