class Round < ApplicationRecord
  include Swagger::Blocks
  belongs_to :tournament
  has_many :matches, -> {order_by_index}, :dependent => :destroy

  attr_accessor :for_team_id


  scope :order_by_index, -> {where(:round_type => :winners).order(index: :asc)}
  scope :only_winners, -> {where(:round_type => :winners).order(index: :asc)}
  scope :only_losers, -> {where(:round_type => :loser).order(index: :asc)}
  scope :only_final, -> {where(:round_type => :final).order(index: :asc)}

  def verify_complete_status
    if self.matches.count == self.matches.where(:status => :complete).count
      self.status = :complete
      next_round = self.tournament.rounds.where("index > ?", self.index).order(index: :asc).first
      if next_round.present?
        next_round.set_playing
        next_round.matches.each do |match|
          match.set_playing
        end
      end
    else
      self.status = :playing
    end
    self.save!(:validate => false)
  end

  def verify_complete_loser_status
    if self.matches.count == self.matches.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL").where(:status => :complete).count
      self.status = :complete
      next_round = self.tournament.rounds_losers.joins(:matches).merge(Match.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL")).where("rounds.index > ?", self.index).order(index: :asc).first
      if next_round.present?
        next_round.set_playing
        next_round.matches.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL").each do |match|
          match.set_playing
        end
      end
    else
      self.status = :playing
    end
    self.save!(:validate => false)
  end

  def verify_complete_final_status
    if self.matches.count == self.matches.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL").where(:status => :complete).count
      self.status = :complete
      next_round = self.tournament.rounds_final.joins(:matches).merge(Match.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL")).where("rounds.index > ?", self.index).order(index: :asc).first
      if next_round.present?
        next_round.set_playing
        next_round.matches.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL").each do |match|
          match.set_playing
        end
      end
    else
      self.status = :playing
    end
    self.save!(:validate => false)
  end

  def verify_complete_loser
    if self.matches.count == self.matches.where("team_a_id IS NOT NULL AND team_b_id IS NOT NULL").count and self.status != 'complete'
      self.status = :playing
      self.matches.each do |match|
        if match.status != 'complete'
          match.set_playing
        end
      end
      self.save!(:validate => false)
    end
  end

  def set_playing
    self.status = :playing
    self.save!(:validate => false)
  end

  swagger_schema :Round do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with round"
    end
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index associated with round"
    end

    property :status do
      key :type, :string
      key :description, "Statusassociated with round"
    end

    property :matches do
      key :type, :array
      items do
        key :'$ref', :Match
      end
      key :description, "Matches associated with round"
    end
  end

  swagger_schema :RoundInput do
    property :index do
      key :type, :integer
      key :format, :int64
      key :description, "Index associated with round"
    end

    property :matches do
      key :type, :array
      items do
        key :'$ref', :MatchInput
      end
      key :description, "Matches associated with round"
    end
  end
end
