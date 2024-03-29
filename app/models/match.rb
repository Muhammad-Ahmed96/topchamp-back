class Match < ApplicationRecord
  include Swagger::Blocks
  belongs_to :round
  belongs_to :team_a, foreign_key: "team_a_id", :class_name => "Team", :optional => true
  belongs_to :team_b, foreign_key: "team_b_id", :class_name => "Team", :optional => true
  belongs_to :team_winner, foreign_key: "team_winner_id", :class_name => "Team", :optional => true
  has_many :sets, :class_name => "MatchSet"

  scope :order_by_index, -> {order(index: :asc)}
  scope :start_date_between, lambda {|start_date, end_date| where("date >= ? AND date <= ?", start_date, end_date ) if start_date.present? and end_date.present?}

  swagger_schema :Match do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with match"
    end
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index id associated with match"
    end
    property :team_a_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team a id associated with match"
    end
    property :team_b_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team b id associated with match"
    end
    property :status do
      key :type, :string
      key :description, "Statusassociated with match"
    end
    property :team_a do
      key :'$ref', :Team
      key :description, "Team a associated with match"
    end
    property :team_b do
      key :'$ref', :EventBracket
      key :description, "Team b associated with match"
    end
    property :seed_team_a do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team a associated with match"
    end
    property :seed_team_b do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team b associated with match"
    end

    property :match_number do
      key :type, :string
      key :description, "Match number associated with match"
    end

    property :court do
      key :type, :string
      key :description, "Court associated with match"
    end

    property :date do
      key :type, :string
      key :description, "Date  associated with match"
    end

    property :start_time do
      key :type, :string
      key :description, "Start time associated with match"
    end

    property :end_time do
      key :type, :string
      key :description, "End time associated with match"
    end
  end

  swagger_schema :MatchInput do
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index id associated with match"
    end
    property :team_a_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team a id associated with match"
    end
    property :team_b_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team b id associated with match"
    end
    property :seed_team_a do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team a associated with match"
    end
    property :seed_team_b do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team b associated with match"
    end


    property :match_number do
      key :type, :string
      key :description, "Match number associated with match"
    end

    property :court do
      key :type, :string
      key :description, "Court associated with match"
    end

    property :date do
      key :type, :string
      key :description, "Date  associated with match"
    end

    property :start_time do
      key :type, :string
      key :description, "Start time associated with match"
    end

    property :end_time do
      key :type, :string
      key :description, "End time associated with match"
    end
  end

  def get_winner_team_id
    is_set_winner = true
    set_won_team_a = 0
    set_won_team_b = 0
    winner_team_id = nil
=begin
    event = self.round.tournament.event
    elimination_format = event.elimination_format
    scoring_option_match_1 = event.scoring_option_match_1
    scoring_option_match_2 = event.scoring_option_match_2
    is_set_winner = false

    sets_count = MatchSet.where(:match_id => self.id).count
    if elimination_format.present?
      if elimination_format.slug == 'single' or elimination_format.slug == 'round_robin'
        if scoring_option_match_1.present? and sets_count == scoring_option_match_1.quantity_games
          is_set_winner = true
        end
      elsif elimination_format.slug == 'double'
        count_match = Match.where(:round_id => self.round_id).where(:team_a_id => self.team_a_id).where(:team_a_id => self.team_a_id).count
        if count_match > 1 and ((scoring_option_match_1.present? and sets_count == scoring_option_match_1.quantity_games) or
            (scoring_option_match_2.present? and sets_count == scoring_option_match_2.quantity_games  ))
          is_set_winner = true
        end
      end
    else
      is_set_winner = true
    end
=end

    MatchSet.where(:match_id => self.id).each do |set|
     score_a =  set.scores.where(:team_id => self.team_a_id).first
     score_b =  set.scores.where(:team_id => self.team_b_id).first
      if score_a.present? and score_b.present?
        if score_a.score > score_b.score
          set_won_team_a = set_won_team_a + 1
        elsif score_a.score < score_b.score
          set_won_team_b = set_won_team_b + 1
        else
          set_won_team_a = set_won_team_a + 1
          set_won_team_b = set_won_team_b + 1
        end
      end
    end
    #score_a = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_a_id).sum(:score)
    #score_b = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:score)

    #time_out_a = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:time_out)
    #time_out_b = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:time_out)

    if is_set_winner
      if set_won_team_a > set_won_team_b
        winner_team_id = self.team_a_id
      elsif set_won_team_a < set_won_team_b
        winner_team_id = self.team_b_id
      end


      self.team_winner_id = winner_team_id
      self.save!(:validate => false)
    end
    return winner_team_id
  end

  def set_complete_status
    self.status = :complete
    self.save!(:validate => false)
  end

  def set_playing
    self.status = :playing
    self.save!(:validate => false)
  end

  def is_loser_bracket?
    self.round.try(:round_type) == 'loser'
  end

  def is_final_bracket?
    self.round.try(:round_type) == 'final'
  end

  def is_winner_bracket?
    self.round.try(:round_type) == 'winners'
  end
end
