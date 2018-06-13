class EventRegistrationRuleSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :allow_group_registrations, :partner, :require_password, :password,
             :require_director_approval, :allow_players_cancel, :use_link_home_page, :link_homepage,:use_link_event_website,
             :link_event_website

end
