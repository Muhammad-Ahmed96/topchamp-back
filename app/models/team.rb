class Team < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  has_and_belongs_to_many :players,-> {order('created_at DESC')}
  has_and_belongs_to_many :players1, -> {order('created_at DESC').limit(0)  }, class_name:'Player'
  has_and_belongs_to_many :players2, -> { order('created_at DESC').limit(0).offset(2)  }, class_name:'Player'
  belongs_to :event
  belongs_to :bracket, class_name: "EventContestCategoryBracketDetail", foreign_key: "event_bracket_id"
  belongs_to :category,  :optional => true

  scope :in_id, lambda {|id| where id: id if id.present?}
  scope :contest_index, lambda {|index| joins(:bracket => [:contest]).merge(EventContest.where(:index => index)) if index}
  scope :category_in, lambda {|id| where(:category_id => id) if id}
  scope :category_like, lambda {|search| joins(:category).merge(Category.where("name LIKE LOWER(?)", "%#{search}%")) if search.present?}
  scope :player_1_like, lambda {|search| joins(:players1 => :user).merge(User.where("LOWER(concat(users.first_name,' ', users.last_name)) LIKE LOWER(?)", "%#{search}%")) if search.present?}
  scope :player_2_like, lambda {|search| joins(:players2 => :user).merge(User.where("LOWER(concat(users.first_name,' ', users.last_name)) LIKE LOWER(?)", "%#{search}%")) if search.present?}
  scope :bracket_like, lambda {|search| joins(:bracket).merge(EventContestCategoryBracketDetail.where("LOWER(concat(event_contest_category_bracket_details.age, event_contest_category_bracket_details.young_age, ' - ', event_contest_category_bracket_details.old_age)) LIKE LOWER(?)", "%#{search}%")
                                  .or(EventContestCategoryBracketDetail.where("LOWER(concat(event_contest_category_bracket_details.lowest_skill,' - ', event_contest_category_bracket_details.highest_skill)) LIKE LOWER(?)", "%#{search}%"))) if  search.present?
  }
  scope :bracket_in, lambda {|id|  where(:event_bracket_id => id) if id}
  scope :skill_filter, lambda {|skill|  joins(:bracket).merge(EventContestCategoryBracketDetail.where("event_contest_category_bracket_details.lowest_skill <= ?", skill).where("event_contest_category_bracket_details.highest_skill >= LOWER(?)", skill).or(EventContestCategoryBracketDetail.where(:lowest_skill => nil).where(:highest_skill => nil))) if skill.present?}


  scope :categories_order, lambda {|column, direction = "desc"| joins(:category).order("categories.#{column} #{direction}") if column.present?}
  scope :contest_order, lambda {|column, direction = "desc"| joins(:bracket => [:contest]).order("event_contests.#{column} #{direction}")if column.present?}
  scope :player_1_order, lambda {|column, direction = "desc"| joins(:players1 => :user).order("users.first_name #{direction}").order("users.last_name #{direction}")if column.present?}
  scope :player_2_order, lambda {|column, direction = "desc"| joins(:players2 => :user).order("users.first_name #{direction}").order("users.last_name #{direction}")if column.present?}
  scope :bracket_order, lambda {|column, direction = "desc"| joins(:bracket).order("event_contest_category_bracket_details.age #{direction}").order("event_contest_category_bracket_details.young_age #{direction}")
                                                                 .order("event_contest_category_bracket_details.old_age #{direction}").order("event_contest_category_bracket_details.lowest_skill #{direction}")
                                                                 .order("event_contest_category_bracket_details.highest_skill #{direction}") if column.present?}



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
