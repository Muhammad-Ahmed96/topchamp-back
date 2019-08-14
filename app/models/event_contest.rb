class EventContest < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  has_many :categories, :class_name => 'EventContestCategory', :dependent => :destroy
  has_many :tournaments, foreign_key: 'contest_id'

  belongs_to :scoring_option_match_1, foreign_key: "scoring_option_match_1_id", class_name: "ScoringOption", optional: true
  belongs_to :scoring_option_match_2, foreign_key: "scoring_option_match_2_id", class_name: "ScoringOption", optional: true
  belongs_to :sport_regulator, optional: true
  belongs_to :elimination_format, optional: true
  #belongs_to :venue, serializer: VenueSerializer
  #
  attr_accessor :filter_categories


  def validate_to_delete
    message = nil
    message = t('not_possible_delete') if !is_for_delete?
    return message
  end

  def is_for_delete?
    result = true
    if self.players.count > 0
      result = false
    end
    result
  end

  def has_players
    !self.is_for_delete?
  end

  def has_score
    self.tournaments.joins(rounds: [matches: [sets: [:scores]]]).count > 0
  end

  def players
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => brackets_ids))
  end

  def brackets_ids
    ids = EventContestCategoryBracketDetail.joins(contest_bracket: [:category])
              .merge(EventContestCategory.where(:event_contest_id => self.id)).pluck(:id)
    ids = ids + EventContestCategoryBracketDetail.where(:event_contest_category_bracket_detail_id => ids).pluck(:id)
    return ids
  end

  swagger_schema :EventContest do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of event"
    end
    property :elimination_format_id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of elimination format associated with event"
    end
    property :scoring_option_match_1_id do
      key :type, :string
      key :description, "Unique identifier of scoring option of match 1 associated with event"
    end
    property :scoring_option_match_2_id do
      key :type, :string
      key :description, "Unique identifier of scoring option of match 2 associated with event"
    end
    property :sport_regulator_id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of sport regulator associated with event"
    end
    property :has_players do
      key :type, :boolean
    end
    property :index do
      key :type, :integer
      key :format, :int64
    end
    property :has_score do
      key :type, :boolean
    end
    property :scoring_option_match_1 do
      key :type, :array
      items do
        key :'$ref', :ScoringOption
      end
      key :description, "Scoring option match 1 associated with event"
    end
    property :scoring_option_match_2 do
      key :type, :array
      items do
        key :'$ref', :ScoringOption
      end
      key :description, "Scoring option match 2 associated with event"
    end
    property :elimination_format do
      key :type, :array
      items do
        key :'$ref', :EliminationFormat
      end
      key :description, "Elimination formats associated with event"
    end
    property :sport_regulator do
      key :type, :array
      items do
        key :'$ref', :SportRegulator
      end
      key :description, "Sport regulators associated with event"
    end
    property :venue do
      key :'$ref', :Venue
      key :description, "Venue associated with event"
    end
    property :categories do
      key :type, :array
      items do
        key :'$ref', :EventContestCategory
      end
      key :description, "Categories associated with contest"
    end
  end
end
