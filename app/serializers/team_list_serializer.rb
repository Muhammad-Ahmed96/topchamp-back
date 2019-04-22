class TeamListSerializer < ActiveModel::Serializer
  attributes :id, :is_in_tournament
  has_many :players, :serializer => PlayerListSerializer
  belongs_to :bracket, :serializer => EventBracketTeamListSerializer
  belongs_to :contest, :serializer => EventContestSingleSerializer
  belongs_to :category, :serializer => CategorySerializer

  def contest
    unless object.bracket.nil?
      EventContest.where(:id => object.bracket.contest_id).first
    end
  end

  def is_in_tournament
    object.is_in_tournament?
  end
end
