class Team < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  has_and_belongs_to_many :players
  belongs_to :event
  belongs_to :bracket, class_name: "EventContestCategoryBracketDetail", foreign_key: "event_bracket_id"
  belongs_to :category,  :optional => true

  scope :in_id, lambda {|id| where id: id if id}
  scope :contest_index, lambda {|index| joins(:bracket => [:contest]).merge(EventContest.where(:contest_index => index)) if index}
  scope :category_in, lambda {|id| where(:category_id => id) if id}
  scope :category_like, lambda {|search| joins(:category).merge(Category.where("name LIKE LOWER(?)")) if "%#{search}%"}
  scope :player_1_like, lambda {|search| joins(:players => :user).merge(User.where["LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?)", "%#{search}%", "%#{search}%"]) if search.present?}
  scope :player_2_like, lambda {|search| joins(:players => :user).merge(User.where["LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?)", "%#{search}%", "%#{search}%"]) if search.present?}
  scope :bracket_like, lambda {|search|
    if search.present?
        joins(:bracket).merge(EventContestCategoryBracketDetail.where("event_contest_category_bracket_details.young_age LIKE LOWER(?) OR event_contest_category_bracket_details.young_age LIKE LOWER(?) OR event_contest_category_bracket_details.old_age LIKE LOWER(?)",
                                                                      "%#{search}%", "%#{search}%", "%#{search}%")
                                  .or(EventContestCategoryBracketDetail.where("event_contest_category_bracket_details.lowest_skill LIKE LOWER(?)", search)))
    end
  }
  scope :skill_filter, lambda {|skill|  joins(:bracket).merge(EventContestCategoryBracketDetail.where("event_contest_category_bracket_details.lowest_skill <= ?", skill).where("event_contest_category_bracket_details.highest_skill >= LOWER(?)", skill).or(EventContestCategoryBracketDetail.where(:lowest_skill => nil).where(:highest_skill => nil))) if skill.present?}

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
