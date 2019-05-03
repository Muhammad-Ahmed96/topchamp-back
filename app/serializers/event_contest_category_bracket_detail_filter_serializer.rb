class EventContestCategoryBracketDetailFilterSerializer < ActiveModel::Serializer
  attributes :id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :status,  :start_date, :time_start, :time_end,
             :has_players,  :contest_index, :current, :partner, :have_score
  has_many :brackets, serializer: EventContestCategoryBracketDetailFilterSerializer

  def brackets
    object.filter_brackets
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

  def have_score
    object.have_score?
  end
end
