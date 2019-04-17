class TeamListSerializer < ActiveModel::Serializer
  attributes :id
  has_many :players, :serializer => PlayerListSerializer
  belongs_to :bracket, :serializer => EventBracketTeamListSerializer
  belongs_to :contest, :serializer => EventContestSingleSerializer
  belongs_to :category, :serializer => CategorySerializer

  def contest
    unless object.bracket.nil?
      EventContest.where(:id => object.bracket.contest_id).first
    end
  end
end
