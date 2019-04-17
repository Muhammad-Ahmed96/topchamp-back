class EventBracketTeamListSerializer < ActiveModel::Serializer
  attributes :id, :age,:young_age, :old_age, :lowest_skill, :highest_skill, :quantity, :start_date, :time_start, :time_end
  belongs_to :parent_bracket, :serializer => EventBracketParentSerializer
end
