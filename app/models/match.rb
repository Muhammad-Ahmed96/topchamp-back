class Match < ApplicationRecord
  include Swagger::Blocks
  belongs_to :round
  belongs_to :team_a, foreign_key: "team_a_id", :class_name => "Team", :optional => true
  belongs_to :team_b, foreign_key: "team_b_id", :class_name => "Team", :optional => true
  has_many :sets, :class_name => "MatchSet"

  scope :order_by_index,-> { order(index: :asc) }

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
    winner_team_id = nil
    score_a = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_a_id).sum(:score)
    score_b = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:score)

    #time_out_a = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:time_out)
    #time_out_b = Score.joins(:set).merge(MatchSet.where(:match_id => self.id)).where(:team_id => self.team_b_id).sum(:time_out)

    if score_a > score_b
      winner_team_id = self.team_a_id
    elsif score_a < score_b
      winner_team_id = self.team_b_id
    end

    self.team_winner_id = winner_team_id
    self.save!(:validate => false)
    return winner_team_id
  end

  def set_complete_status
    self.status = :complete
    self.save!(:validate => false)
  end
end
