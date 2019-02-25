class EventContestFilterCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :bracket_types, :event_contest_id, :has_players, :contest_id, :contest_index
  has_many :brackets, serializer: EventContestCategoryFilterBracketSerializer

  def id
    object.category.id
  end

  def name
    object.category.name
  end

  def contest_id
    object.contest.id
  end

  def contest_index
    object.contest.index
  end

  def brackets
    brackets = []
    allow_age_range = object.allow_age_range
    age = object.user_age
    skill = object.user_skill
    only_brackets = object.only_brackets
    object.brackets.each do |bracket|
      valid_to_add = false
      type = bracket.bracket_type
      bracket.allow_age_range = object.allow_age_range
      bracket.user_age = object.user_age
      bracket.user_skill = object.user_skill
      bracket.bracket_type = type
      bracket.ignore_brackets = object.ignore_brackets
      bracket.only_brackets = only_brackets

      case type
      when 'age'
        details = bracket.details.age_filter(age, allow_age_range).not_in(bracket.ignore_brackets)
        details = details.where(:id => only_brackets) if only_brackets
        if details.length > 0
          valid_to_add = true
        end
      when 'skill'
        details = bracket.details.skill_filter(skill).not_in(bracket.ignore_brackets)
        details = details.where(:id => only_brackets) if only_brackets
        if details.length > 0
          valid_to_add = true
        end
      when 'skill_age'
        details = bracket.details.skill_filter(skill).not_in(bracket.ignore_brackets)
        details = details.where(:id => only_brackets) if only_brackets
        details.each do |detail|
          bc  = detail.brackets.age_filter(age, allow_age_range).not_in(bracket.ignore_brackets)
          bc = bc.where(:id => only_brackets) if only_brackets
          if bc.length > 0
            valid_to_add = true
            break
          end
        end
      when 'age_skill'
        details = bracket.details.age_filter(age, allow_age_range).not_in(bracket.ignore_brackets)
        details = details.where(:id => only_brackets) if only_brackets
        details.each do |detail|
          bc = detail.brackets.skill_filter(skill).not_in(bracket.ignore_brackets)
          bc = bc.where(:id => only_brackets) if only_brackets
          if bc.length > 0
            valid_to_add = true
            break
          end
        end
      end
      if valid_to_add
        brackets << bracket
      end
    end
    brackets
  end
end
