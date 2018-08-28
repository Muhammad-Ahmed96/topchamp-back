class Team < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  has_and_belongs_to_many :players
  belongs_to :event
  belongs_to :bracket, class_name: "EventBracket", foreign_key: "event_bracket_id"
  belongs_to :category


  def seed(tournament_id)
    seed = nil
    match = Match.joins(:round).merge(Round.where(:id => tournament_id)).where.not(:seed_team_a => nil).where.not(:seed_team_b => nil)
    .where("team_a_id = ? OR team_b_id = ?", self.id, self.id).distinct.first
    if match.present?
      if match.seed_team_a.present? and match.team_a_id == self.id
        seed = match.seed_team_a
      elsif match.seed_team_b.present? and match.team_b_id == self.id
        seed = match.seed_team_b
      end
    end
    return seed
  end

  swagger_schema :Team do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with team"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with team"
    end

    property :event do
      key :'$ref', :Event
      key :description, "Event associated with team"
    end
    property :bracket do
      key :'$ref', :EventBracket
      key :description, "Bracket associated with team"
    end
    property :category do
      key :'$ref', :Category
      key :description, "category associated with team"
    end

    property :players do
      key :type, :array
      items do
        key :'$ref', :Player
      end
      key :description, "Players associated with team"
    end
  end
end
