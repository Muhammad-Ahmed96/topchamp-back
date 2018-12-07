class EventContest < ApplicationRecord
  include Swagger::Blocks
  belongs_to :event
  has_many :categories, :class_name => 'EventContestCategory', :dependent => :destroy

  belongs_to :scoring_option_match_1, foreign_key: "scoring_option_match_1_id", class_name: "ScoringOption", optional: true
  belongs_to :scoring_option_match_2, foreign_key: "scoring_option_match_2_id", class_name: "ScoringOption", optional: true
  belongs_to :sport_regulator, optional: true
  belongs_to :elimination_format, optional: true


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

  def players
    ids = EventContestCategoryBracketDetail.joins(:category)
              .merge(EventContestCategory.where(:event_contest_id => self.id)).pluck(:id)
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => ids))
  end
end
