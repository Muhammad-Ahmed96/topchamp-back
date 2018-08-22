class TournamentMatchesStatus < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.to_sym] = item.text
    end
    items
  end

end

class TournamentMatchesStatus::Complete < TournamentMatchesStatus
end

class TournamentMatchesStatus::NotComplete < TournamentMatchesStatus
end
