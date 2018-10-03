class ScoringOptionSerializer < ActiveModel::Serializer
  attributes :id, :description, :quantity_games, :winner_games, :points, :duration, :win_by
end
