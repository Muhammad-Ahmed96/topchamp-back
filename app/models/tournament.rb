class Tournament < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  belongs_to :bracket, :class_name => "EventBracket", :foreign_key => "event_bracket_id"
  belongs_to :category

  has_many :rounds, -> {order_by_index}, :dependent => :destroy

  scope :matches_status_in, lambda {|progress| where matches_status: progress if progress.present?}
  scope :teams_count_in, lambda {|count| where teams_count: progress if count.present?}
  scope :event_in, lambda {|search| joins(:event).merge(Event.where id: search) if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where("title LIKE ?", "%#{search}%")) if search.present?}
  scope :category_in, lambda {|search| joins(:category).merge(Category.where id: search) if search.present?}
  scope :bracket_in, lambda {|search| joins(:bracket).merge(EventBracket.where id: search) if search.present?}
  scope :bracket_like, lambda {|search| joins(:bracket).merge(EventBracket.where("to_char(age,'999') LIKE ? OR to_char(lowest_skill,'9999') like ? OR to_char(highest_skill,'9999') LIKE ? OR to_char(young_age,'9999') LIKE ? OR to_char(old_age,'9999') LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")) if search.present?}

  scope :event_order, lambda {|column, direction = "desc"| includes(:event).order("events.#{column} #{direction}") if column.present?}
  scope :category_order, lambda {|column, direction = "desc"| includes(:category).order("categories.#{column} #{direction}") if column.present?}
  scope :bracket_order, lambda {|column, direction = "desc"| includes(:bracket).order("event_brackets.age #{direction}").order("event_brackets.lowest_skill #{direction}")
                                                                 .order("event_brackets.highest_skill #{direction}").order("event_brackets.young_age #{direction}").order("event_brackets.old_age #{direction}") if column.present?}

  def sync_matches!(data)
    deleteIds = []
    if data.present?
      data.each do |item|
        match_ids = []
        if item[:id].present?
          round = self.rounds.where(:id => item[:id]).update_or_create!({:index => item[:index]})
        else
          round = self.rounds.where(:index => item[:index]).first_or_create!({:index => item[:index]})
        end
        if item[:matches].present?
          item[:matches].each do |item_match|
            if item_match[:id].present?
              match = round.matches.where(:id => item_match[:id]).update_or_create!(item_match)
            else
              match = round.matches.where(:index => item_match[:index]).update_or_create!(item_match)
            end
            match_ids << match.id
          end
        end
        round.matches.where.not(:id => match_ids).destroy_all
        deleteIds << round.id
      end
    else
      self.rounds.where.not(id: deleteIds).destroy_all
    end
    self.set_team_count
    self.set_matches_status
  end

  def total_teams
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    count = Team.where(:id => teams_ids).where(:event_id => self.event_id).where(:category_id => self.category_id)
                .where(:event_bracket_id => self.event_bracket_id).count
    return count
  end

  def set_team_count
    self.update_attributes(:teams_count => self.total_teams)
  end

  def set_matches_status
    event = Event.where(:id => self.event_id).first
    if event.present?
      count = event.teams.where(:event_bracket_id => self.event_bracket_id).where(:category_id => self.category_id).count
      if count == self.total_teams
        self.update_attributes(:matches_status => :complete)
      else
        self.update_attributes(:matches_status => :not_complete)
      end
    end
  end

  def teams
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    Team.where(:id => teams_ids).where(:event_id => self.event_id).where(:category_id => self.category_id)
        .where(:event_bracket_id => self.event_bracket_id)
  end

  def set_winner(match)
    logger::info("set_winner")
    next_round = self.rounds.where("index > ?", match.round.index).order(index: :asc).first
    if next_round.present?
      next_match_info = self.get_index_match(match.index)
      logger::info next_match_info
      next_match = next_round.matches.where(:index => next_match_info[:index]).order(index: :asc).first
      if next_match.present?
        winner_team_id = match.get_winner_team_id
        if next_match_info[:type] == 'A'
          next_match.team_a_id = winner_team_id
        elsif next_match_info[:type] == 'B'
          next_match.team_b_id = winner_team_id
        end
        next_match.save!(:validate => false)
      end
    end

  end

  def get_index_match(match_index)
    next_index = nil
    # total_rounds = Math.log(self.teams_count) / Math.log(2)
    rest = (((match_index + 2) / 2.to_f) - 1)
    next_index = rest.to_i
    type = rest.modulo(1) == 0 ? 'A' : 'B'
    return {:index => next_index, :type => type}
  end

  swagger_schema :Tournament do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with tournament"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with tournament"
    end
    property :event_bracket_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event bracket id associated with tournament"
    end
    property :category_id do
      key :type, :integer
      key :format, :int64
      key :description, "Category id associated with tournament"
    end

    property :teams_count do
      key :type, :integer
      key :format, :int64
      key :description, "Teams count associated with tournament"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with tournament"
    end
    property :matches_progress do
      key :type, :string
      key :description, "Matches progress associated with tournament"
    end
    property :event do
      key :'$ref', :Event
      key :description, "Event associated with tournament"
    end

    property :bracket do
      key :'$ref', :EventBracket
      key :description, "Bracket associated with tournament"
    end

    property :category do
      key :'$ref', :Category
      key :description, "Category associated with tournament"
    end

    property :rounds do
      key :type, :array
      items do
        key :'$ref', :Round
      end
      key :description, "Rounds associated with tournament"
    end
  end
end
