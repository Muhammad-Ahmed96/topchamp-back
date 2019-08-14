class EventContestCategoryBracket < ApplicationRecord
  include Swagger::Blocks
  belongs_to :category, :class_name => 'EventContestCategory',:foreign_key => 'event_contest_category_id',
             :optional => true

  has_many :details, class_name: "EventContestCategoryBracketDetail", :dependent => :destroy

  attr_accessor :status
  attr_accessor :user_age
  attr_accessor :user_skill
  attr_accessor :allow_age_range
  attr_accessor :ignore_brackets
  attr_accessor :only_brackets
  attr_accessor :filter_details

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

  def players
    Player.joins(:brackets_enroll).merge(PlayerBracket.where(:event_bracket_id => brackets_ids))
  end

  def brackets_ids
    ids = EventContestCategoryBracketDetail.joins(:contest_bracket)
              .merge(EventContestCategoryBracket.where(:id => self.id)).pluck(:id)
    ids = ids + EventContestCategoryBracketDetail.where(:event_contest_category_bracket_detail_id => ids).pluck(:id)
    return ids
  end

  swagger_schema :EventContestCategoryBracket do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier of bracket"
    end
    property :awards_for do
      key :type, :string
      key :description, "Defines awards for associated with event"
    end
    property :awards_through do
      key :type, :string
      key :description, "Defines awards through associated with event"
    end
    property :awards_plus do
      key :type, :string
      key :description, "Defines a awards plus associated with event"
    end
    property :bracket_type do
      key :type, :string
      key :description, "Type of bracket associated with event\nExample: Age, Skill, Age/Skill or SkillAge"
    end
    property :has_players do
      key :type, :boolean
    end
    property :details do
      key :type, :array
      items do
        key :'$ref', :EventBracket
      end
      key :description, "Brackets associated with event"
    end
  end
end
