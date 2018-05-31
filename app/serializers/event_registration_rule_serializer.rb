class EventRegistrationRuleSerializer < ActiveModel::Serializer
  attributes :id, :event_id, :allow_group_registrations, :partner, :require_password, :anyone_require_password, :password,
             :require_director_approval, :allow_players_cancel, :link_homepage, :link_event_website, :use_app_event_website,
             :link_app

end
