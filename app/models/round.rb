class Round < ApplicationRecord
  include Swagger::Blocks
  belongs_to :tournament
  has_many :matches, -> {order_by_index}, :dependent => :destroy

  attr_accessor :for_team_id


  scope :order_by_index,-> { order(index: :asc) }

  def verify_complete_status
    if self.matches.count == self.matches.where(:status => :complete).count
      self.status = :complete
      next_round =  self.tournament.rounds.where("index > ?", self.index).order(index: :asc).first
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
