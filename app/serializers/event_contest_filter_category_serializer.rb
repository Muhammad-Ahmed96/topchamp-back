class EventContestFilterCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :bracket_types, :event_contest_id, :has_players, :contest_id, :contest_index, :has_score
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
    object.filter_brackets
  end
end
