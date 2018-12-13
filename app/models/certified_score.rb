class CertifiedScore < ApplicationRecord
  include Swagger::Blocks
  acts_as_paranoid
  belongs_to :user
  belongs_to :event
  belongs_to :match
  belongs_to :tournament
  belongs_to :team_a, foreign_key: "team_a_id", :class_name => "Team", :optional => true
  belongs_to :team_b, foreign_key: "team_b_id", :class_name => "Team", :optional => true
  belongs_to :team_winner, foreign_key: "team_winner_id", :class_name => "Team", :optional => true

  has_attached_file :signature, :path => ":rails_root/public/images/certified_score/:to_param/:style/:basename.:extension",
                    :url => "/images/player/:to_param/:style/:basename.:extension",
                    styles: {medium: "100X100>", thumb: "50x50>"}, default_url: "/assets/missing.png"
  validates_attachment_content_type :signature, content_type: /\Aimage\/.*\z/

  swagger_schema :CertifiedScore do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with certified score"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with certified score"
    end
    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id associated with certified score"
    end
    property :match_id do
      key :type, :integer
      key :format, :int64
      key :description, "Match id associated with certified score"
    end
    property :tournament_id do
      key :type, :integer
      key :format, :int64
      key :description, "Tournament id associated with certified score"
    end

    property :round_id do
      key :type, :integer
      key :format, :int64
      key :description, "Round id associated with certified score"
    end

    property :team_a_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team a id associated with certified score"
    end

    property :team_b_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team a id associated with certified score"
    end


    property :team_winner_id do
      key :type, :integer
      key :format, :int64
      key :description, "Team winner id associated with certified score"
    end

    property :user_id do
      key :type, :integer
      key :format, :int64
      key :description, "User id id associated with certified score"
    end
    property :created_at do
      key :type, :string
      key :description, "Created at associated with certified score"
    end

    property :signature do
      key :type, :string
      key :description, "Signature associated with certified score"
    end
    property :status do
      key :type, :string
      key :description, "Status associated with certified score"
    end
  end
end
