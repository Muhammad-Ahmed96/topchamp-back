class EventContestCategoryBracketDetailFilterSerializer < ActiveModel::Serializer
  attributes :id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :status,  :start_date, :time_start, :time_end
  has_many :brackets, serializer: EventContestCategoryBracketDetailFilterSerializer

  def brackets
    brackets = []
    type = object.bracket_type
    age = object.user_age
    allow_age_range = object.allow_age_range
    skill = object.user_skill
    case type
    when 'age', 'skill'
      brackets = []
    when 'skill_age'
      brackets = object.brackets.age_filter(age, allow_age_range).not_in( object.ignore_brackets)
    when 'age_skill'
      brackets = object.brackets.skill_filter(skill).not_in( object.ignore_brackets)
    end
    brackets.each do |item|
      item.bracket_type = object.bracket_type
      item.user_age = object.user_age
      item.allow_age_range = object.allow_age_range
      item.user_skill = object.user_skill
      item.ignore_brackets = object.ignore_brackets
    end
    brackets
  end

  def time_start
    unless object.time_start.nil?
      object.time_start.strftime("%H:%M:%S")
    end
  end

  def time_end
    unless object.time_end.nil?
      object.time_end.strftime("%H:%M:%S")
    end
  end
end
