class TournamentWithTeamsSerializer < ActiveModel::Serializer
  def initialize(*args)
    super
    instance_options[:tournament_id] = object.id
  end
  attributes :id, :event_id, :event_bracket_id, :category_id, :status, :teams_count, :matches_status, :winner_team_id,
             :contest_id, :event_contest_category_id

  belongs_to :event, :serializer => EventSingleSerializer
  belongs_to :contest, :serializer => EventContestSingleSerializer
  belongs_to :bracket, :serializer => EventBracketParentSerializer
  belongs_to :category, :serializer => CategorySerializer
  has_many :rounds, :serializer => RoundSingleSerializer
  has_many :rounds_losers, :serializer => RoundSingleSerializer
  has_many :rounds_final, :serializer => RoundSingleSerializer
  has_many :teams, :serializer => TeamWithSeedSerializer
  has_one :winner_team, :serializer => TeamSingleSerializer
end
