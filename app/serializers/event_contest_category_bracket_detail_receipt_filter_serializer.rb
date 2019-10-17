class EventContestCategoryBracketDetailReceiptFilterSerializer < ActiveModel::Serializer
  attributes :id, :age, :young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :status,  :start_date,
             :time_start, :time_end, :receipt
  has_many :brackets, serializer: EventContestCategoryBracketDetailReceiptFilterSerializer

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

  def receipt
    object.receipt
  end
end