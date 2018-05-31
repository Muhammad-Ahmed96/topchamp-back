class EliminationFormat < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.to_sym] = item.text
    end
    items
  end

end

class EliminationFormat::SingleElimination < EliminationFormat
end
class EliminationFormat::DoubleElimination < EliminationFormat
end
class EliminationFormat::RoundRobinElimination < EliminationFormat
end
class EliminationFormat::RoundRobinDoubleSplit < EliminationFormat
end
class EliminationFormat::RoundRobinTripleSplit < EliminationFormat
end
class EliminationFormat::RoundRobinQuadrupleSplit < EliminationFormat
end
class EliminationFormat::Multilevel < EliminationFormat
end
class EliminationFormat::Extended < EliminationFormat
end
class EliminationFormat::NoCompetition < EliminationFormat
end
