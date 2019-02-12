class EventContestCategoryFilterBracketSerializer < ActiveModel::Serializer
  attributes :id,:awards_for, :awards_through, :awards_plus, :bracket_type, :bracket, :has_players
  has_many :details, serializer: EventContestCategoryBracketDetailFilterSerializer

  def details
    details = []
    type = object.bracket_type
    age = object.user_age
    allow_age_range = object.allow_age_range
    skill = object.user_skill
    case type
    when 'age', 'age_skill'
      details = object.details.age_filter(age, allow_age_range).not_in( object.ignore_brackets)
    when 'skill_age', 'skill'
      details = object.details.skill_filter(skill).not_in( object.ignore_brackets)
    end
    details.each do |item|
      item.bracket_type = object.bracket_type
      item.user_age = object.user_age
      item.allow_age_range = object.allow_age_range
      item.user_skill = object.user_skill
      item.ignore_brackets = object.ignore_brackets
    end
    details
  end

  def bracket
    unless object.bracket_type.nil?
      Bracket.collection[object.bracket_type.to_sym]
    end
  end
end
