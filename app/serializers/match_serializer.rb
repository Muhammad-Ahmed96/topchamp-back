class MatchSerializer < ActiveModel::Serializer
  def initialize(*args)
    super
    instance_options[:match_id] = object.id
  end
  attributes :id, :index, :team_a_id, :team_b_id,:status, :seed_team_a, :seed_team_b, :match_number
  belongs_to :team_a, serializer: TeamSingleSerializer
  belongs_to :team_b, serializer: TeamSingleSerializer

  has_many :sets, serializer: SetSerializer


end
