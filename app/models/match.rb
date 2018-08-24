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
      key :description, "Seed team a associated with round"
    end
    property :seed_team_b do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team b associated with round"
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
      key :description, "Seed team a associated with round"
    end
    property :seed_team_b do
      key :type, :integer
      key :format, :int64
      key :description, "Seed team b associated with round"
    end
  end
end
