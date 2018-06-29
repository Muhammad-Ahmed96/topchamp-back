class EventSingleSerializer < ActiveModel::Serializer
  attributes :id, :title, :icon, :description, :start_date, :end_date, :visibility,
             :event_url, :is_event_sanctioned, :sanctions, :organization_name, :organization_url,
             :is_determine_later_venue, :access_code, :status, :creator_user_id, :sport_regulator_id,
             :elimination_format_id, :bracket_by, :scoring_option_match_1_id, :scoring_option_match_2_id, :sport_regulator_id,
             :awards_for, :awards_through, :awards_plus
end
