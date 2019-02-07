class EventContestFilterSerializer < ActiveModel::Serializer
  attributes :id, :elimination_format_id, :scoring_option_match_1_id, :scoring_option_match_2_id, :sport_regulator_id,
             :has_players, :index

  has_many :categories, serializer: EventContestFilterCategorySerializer
end
