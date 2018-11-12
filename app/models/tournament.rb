class Tournament < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  belongs_to :bracket, :class_name => "EventBracket", :foreign_key => "event_bracket_id"
  belongs_to :category

  has_many :rounds, -> {order_by_index}, :dependent => :destroy
  has_many :rounds_all, :dependent => :destroy, class_name: 'Round'
  has_many :rounds_losers, -> {only_losers}, :dependent => :destroy, class_name: 'Round'
  has_many :rounds_final, -> {only_final}, :dependent => :destroy, class_name: 'Round'

  belongs_to :winner_team, :class_name => "Team", :foreign_key => "winner_team_id", :optional => true

  scope :matches_status_in, lambda {|progress| where matches_status: progress if progress.present?}
  scope :teams_count_in, lambda {|count| where teams_count: count if count.present?}
  scope :event_in, lambda {|search| joins(:event).merge(Event.where id: search) if search.present?}
  scope :event_like, lambda {|search| joins(:event).merge(Event.where("LOWER(title) LIKE LOWER(?)", "%#{search}%")) if search.present?}
  scope :category_in, lambda {|search| joins(:category).merge(Category.where id: search) if search.present?}
  scope :bracket_in, lambda {|search| joins(:bracket).merge(EventBracket.where id: search) if search.present?}
  scope :bracket_like, lambda {|search| joins(:bracket).merge(EventBracket.where("to_char(age,'999') LIKE ? OR to_char(lowest_skill,'9999') like ? OR to_char(highest_skill,'9999') LIKE ? OR to_char(young_age,'9999') LIKE ? OR to_char(old_age,'9999') LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")) if search.present?}

  scope :event_order, lambda {|column, direction = "desc"| includes(:event).order("events.#{column} #{direction}") if column.present?}
  scope :category_order, lambda {|column, direction = "desc"| includes(:category).order("categories.#{column} #{direction}") if column.present?}
  scope :bracket_order, lambda {|column, direction = "desc"| includes(:bracket).order("event_brackets.age #{direction}").order("event_brackets.lowest_skill #{direction}")
                                                                 .order("event_brackets.highest_skill #{direction}").order("event_brackets.young_age #{direction}").order("event_brackets.old_age #{direction}") if column.present?}

  def sync_matches!(data, losers_params = nil)
    Score.joins(set: [match: [round: [:tournament]]]).merge(Tournament.where :id => self.id).destroy_all
    MatchSet.joins(match: [round: [:tournament]]).merge(Tournament.where :id => self.id).destroy_all
    deleteIds = []
    loserDeleteIds = []
    if data.present?
      data.each do |item|
        match_ids = []
        if item[:id].present?
          round = self.rounds.where(:id => item[:id]).where(round_type: :winners).update_or_create!({:index => item[:index]})
        else
          round = self.rounds.where(:index => item[:index]).where(round_type: :winners).first_or_create!({:index => item[:index]})
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
      self.rounds.where.not(id: deleteIds).where(round_type: :winners).destroy_all
    end
    self.update_internal_data
    if self.matches_status == 'complete'
      self.set_playing
      round = self.rounds.where(:index => 0).first
      if round.present?
        round.set_playing
        round.matches.each do |match|
          match.set_playing
        end
      end
    end
    #Save loser bracket
    if losers_params.present?
      losers_params.each do |item|
        match_ids = []
        if item[:id].present?
          round = self.rounds_losers.where(:id => item[:id]).update_or_create!({:index => item[:index], :round_type => :loser})
        else
          round = self.rounds_losers.where(:index => item[:index]).first_or_create!({:index => item[:index], :round_type => :loser})
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
        loserDeleteIds << round.id
      end
    else
      self.rounds.where.not(id: loserDeleteIds).where(round_type: :losser).destroy_all
    end
  end

  def total_teams
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Round.where(:round_type => :winners)).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Round.where(:round_type => :winners)).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    count = Team.where(:id => teams_ids).where(:event_id => self.event_id).where(:category_id => self.category_id)
                .where(:event_bracket_id => self.event_bracket_id).count
    return count
  end

  def reset_general_score
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    Team.where(:id => teams_ids).where(:event_id => self.event_id).where(:category_id => self.category_id)
        .where(:event_bracket_id => self.event_bracket_id).update({:general_score => 0, :match_won => 0})
  end

  def reset_match_winner
    Match.joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.update(:team_winner_id => nil)
  end

  def set_team_count
    self.update_attributes(:teams_count => self.total_teams)
  end

  def set_matches_status
    event = Event.where(:id => self.event_id).first
    if event.present?
      count = event.teams.where(:event_bracket_id => self.event_bracket_id).where(:category_id => self.category_id).count
      if count == self.total_teams and self.total_teams > 0
        self.update_attributes(:matches_status => :complete)
      else
        self.update_attributes(:matches_status => :not_complete)
      end
    end
  end

  def update_internal_data
    self.set_team_count
    self.set_matches_status
    self.reset_general_score
    self.reset_match_winner
  end

  def teams
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Round.where(round_type: :winners)).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Round.where(round_type: :winners)).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    Team.where(:id => teams_ids).where(:event_id => self.event_id).where(:category_id => self.category_id)
        .where(:event_bracket_id => self.event_bracket_id)
  end

  def set_winner(match)
    last_winner_team_id = match.team_winner_id
    elimination_format = self.event.elimination_format
    winner_team_id = nil
    unless elimination_format.nil?
      #Logic for single elimination
      if elimination_format.slug == 'single'
        next_round = self.rounds.where("index > ?", match.round.index).where(round_type: :winners).order(index: :asc).first
        if next_round.present?
          next_match_info = self.get_index_match(match.index)
          next_match = next_round.matches.where(:index => next_match_info[:index]).order(index: :asc).first
          winner_team_id = match.get_winner_team_id
          if next_match.present?
            if next_match_info[:type] == 'A'
              next_match.team_a_id = winner_team_id
            elsif next_match_info[:type] == 'B'
              next_match.team_b_id = winner_team_id
            end
            next_match.save!(:validate => false)
          end
        else
          winner_team_id = match.get_winner_team_id
        end
        match.set_complete_status
        match.round.verify_complete_status
        #Logic for round_robin elimination
      elsif elimination_format.slug == 'round_robin'
        winner_team_id = match.get_winner_team_id
        match.set_complete_status
        match.round.verify_complete_status
      elsif elimination_format.slug == 'double'
        last_match_loser = Match.joins(:round).merge(Round.where(:id => self.rounds_losers.pluck(:id))).select("MAX(CAST(COALESCE(NULLIF(regexp_replace(matches.match_number, '[^-0-9.]+', '', 'g'),''),'0') AS numeric)) AS match_number").all
        last_match = Match.joins(:round).merge(Round.where(:id => self.rounds.pluck(:id))).select("MAX(CAST(COALESCE(NULLIF(regexp_replace(matches.match_number, '[^-0-9.]+', '', 'g'),''),'0') AS numeric)) AS match_number").all
        last_match = last_match.length > 0 ? last_match[0][:match_number]: 0
        last_match_loser = last_match_loser.length > 0 ? last_match_loser[0][:match_number]: 0
        if match.is_winner_bracket?
          #Winner bracket
          next_round = self.rounds.where("index > ?", match.round.index).where(round_type: :winners).order(index: :asc).first
          if next_round.present?
            next_match_info = self.get_index_match(match.index)
            loser_next_match = next_round.matches.where(:index => next_match_info[:index]).order(index: :asc).first
            winner_team_id = match.get_winner_team_id
            if loser_next_match.present?
              if next_match_info[:type] == 'A'
                loser_next_match.team_a_id = winner_team_id
              elsif next_match_info[:type] == 'B'
                loser_next_match.team_b_id = winner_team_id
              end
              loser_next_match.save!(:validate => false)
            end
          else
            winner_team_id = match.get_winner_team_id
          end
          match.set_complete_status
          match.round.verify_complete_status
          # Losers bracket
          loser_team_id = 0
          if match.team_a_id == winner_team_id
            loser_team_id = match.team_b_id
          else
            loser_team_id = match.team_a_id
          end
          loser_next_round = self.rounds_losers.joins(:matches).merge(Match.where(:loser_match_a => match.match_number).or(Match.where(loser_match_b: match.match_number))).first
          if loser_next_round.present?
            loser_next_match = loser_next_round.matches.where("loser_match_a = ? OR loser_match_b = ?",match.match_number, match.match_number ).first
            unless loser_next_match.nil?
              if loser_next_match.loser_match_a.to_s == match.match_number.to_s
                loser_next_match.team_a_id = loser_team_id
              elsif loser_next_match.loser_match_b.to_s == match.match_number.to_s
                loser_next_match.team_b_id = loser_team_id
              end
              loser_next_match.save!(:validate => false)
            end
            loser_next_match.round.verify_complete_loser
          end
          #Create final round
          if last_match.to_s == match.match_number.to_s
            self.create_last_match(last_match_loser, winner_team_id , nil)
          end
        elsif match.is_loser_bracket?
          #move on loser bracket only
          next_round = self.rounds_losers.where("index > ?", match.round.index).order(index: :asc).first
          if next_round.present?
            loser_next_match = next_round.matches.where("loser_match_a = ? OR loser_match_b = ?",match.match_number, match.match_number).first
            loser_winner_team_id = match.get_winner_team_id
            if loser_next_match.present?
              if loser_next_match.loser_match_a.to_s == match.match_number.to_s
                loser_next_match.team_a_id = loser_winner_team_id
              elsif loser_next_match.loser_match_b.to_s == match.match_number.to_s
                loser_next_match.team_b_id = loser_winner_team_id
              end
              loser_next_match.save!(:validate => false)
            end
          else
            loser_winner_team_id = match.get_winner_team_id
          end
          match.set_complete_status
          match.round.verify_complete_loser_status
          #Create final round
          if last_match_loser.to_s == match.match_number.to_s
            self.create_last_match(last_match_loser, nil , loser_winner_team_id)
          end
        elsif match.is_final_bracket?
          winner_team_id = match.get_winner_team_id
          round = match.round
          if round.index == 0
            if winner_team_id.to_s == match.team_a_id.to_s
              #save winer ans finish tournament
              self.winner_team_id = winner_team_id
              self.save!(:validate => false)
            elsif  winner_team_id.to_s == match.team_b_id.to_s
              #Extra round loser win
              round = self.rounds_final.where(:index => 1).update_or_create!({:index => 1, :round_type => :final})
              match = round.matches.where(:index => 0).update_or_create!({:match_number => ++match.match_number, :team_a_id => match.team_a_id, :team_b_id =>  match.team_b_id})
              round.set_playing
              round.matches.each do |match|
                if match.status != 'complete'
                  match.set_playing
                end
              end
            end
          else
            #save winer and finish tournament
            self.winner_team_id = winner_team_id
            self.save!(:validate => false)
          end
          match.set_complete_status
          match.round.verify_complete_final_status
        end
      end
      self.verify_complete_status
    end
    #save general scores of teams
    #rest last team match won
    unless last_winner_team_id.nil?
      last_team = Team.where(:id => last_winner_team_id).first
      if last_team.present?
        if last_team.match_won > 0
          last_team.match_won = last_team.match_won - 1
          last_team.save!(:validate => false)
        end
      end
    end
    teams_ids = [match.team_a_id, match.team_b_id]
    teams_ids.each do |team_id|
      team = Team.where(:id => team_id).first
      if team.present?
        score = Score.where(:team_id => team_id).sum(:score)
        team.general_score = score
        if winner_team_id == team_id
          team.match_won = team.match_won + 1
        end
        team.save!(:validate => false)
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

  def verify_complete_status
    elimination_format = self.event.elimination_format
    if self.rounds_all.count == self.rounds_all.where(:status => :complete).count
      self.status = :complete
      if elimination_format.slug != 'double'
        set_team_tournament_winner
      else
        #todo winner doubles
      end

    else
      self.status = :playing
    end
    self.save!(:validate => false)
  end

  def set_playing
    self.status = :playing
    self.save!(:validate => false)
  end

  #todo get list of position
  def get_position_list

  end

  def set_team_tournament_winner
    matchs_a = Match.where.not(:team_a_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_a_id)
    matchs_b = Match.where.not(:team_b_id => nil).joins(round: :tournament).merge(Tournament.where(:id => self.id)).distinct.pluck(:team_b_id)
    teams_ids = matchs_a + matchs_b
    winner_team = Team.where(:id => teams_ids).order(match_won: :asc).order(general_score: :asc).first
    if winner_team.present?
      self.winner_team_id = winner_team.id
      self.save!(:validate => false)
    end
  end

  def create_last_match(last_match_number, team_a_id, team_b_id)
    round = self.rounds_final.where(:index => 0).update_or_create!({:index => 0, :round_type => :final})
    data = {:match_number => ++last_match_number}
    unless team_a_id.nil?
      data[:team_a_id] = team_a_id
    end
    unless team_b_id.nil?
      data[:team_b_id] = team_b_id
    end
    match = round.matches.where(:index => 0).update_or_create!(data)
    if match.team_a_id.present? and match.team_b_id.present?
      round.set_playing
      round.matches.each do |match|
        if match.status != 'complete'
          match.set_playing
        end
      end
    end
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
