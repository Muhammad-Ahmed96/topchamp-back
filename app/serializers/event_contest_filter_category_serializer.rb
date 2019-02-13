class EventContestFilterCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :bracket_types, :event_contest_id,   :has_players
  has_many :brackets, serializer: EventContestCategoryFilterBracketSerializer

  def id
    object.category.id
  end

  def name
    object.category.name
  end

  def brackets
    brackets = []
    allow_age_range = object.allow_age_range
    age = object.user_age
    skill = object.user_skill
    object.brackets.each do |bracket|
      valid_to_add = false
      type = bracket.bracket_type
      bracket.allow_age_range = object.allow_age_range
      bracket.user_age = object.user_age
      bracket.user_skill = object.user_skill
      bracket.bracket_type = type
      bracket.ignore_brackets = object.ignore_brackets

      case type
      when 'age'
        details = bracket.details.age_filter(age, allow_age_range).not_in( bracket.ignore_brackets)
        if details.length > 0
          valid_to_add = true
        end
      when 'skill'
        details = bracket.details.skill_filter(skill).not_in( bracket.ignore_brackets)
        if details.length > 0
          valid_to_add = true
        end
      when 'skill_age'
        bracket.details.skill_filter(skill).not_in( bracket.ignore_brackets).each do |detail|
          if detail.brackets.age_filter(age, allow_age_range).not_in( bracket.ignore_brackets).length > 0
            valid_to_add = true
            break
          end
        end
      when 'age_skill'
        bracket.details.age_filter(age, allow_age_range).not_in( bracket.ignore_brackets).each do |detail|
          if detail.brackets.skill_filter(skill).not_in( bracket.ignore_brackets).length > 0
            valid_to_add = true
            break
          end
        end
      end
      if  valid_to_add
        brackets << bracket
      end
    end
    brackets
  end
end
