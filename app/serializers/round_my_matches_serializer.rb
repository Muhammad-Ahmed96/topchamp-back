class RoundMyMatchesSerializer < ActiveModel::Serializer
  attributes :id, :index, :status, :matches
  def matches
    object.matches.where("team_a_id = ? OR team_b_id = ?",  object.for_team_id,  object.for_team_id)
  end
end
