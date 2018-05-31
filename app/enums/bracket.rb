class Bracket < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.to_sym] = item.text
    end
    items
  end

end

class Bracket::Age < Bracket
end
class Bracket::AgeSkill < Bracket
end
class Bracket::Skill < Bracket
end
class Bracket::SkillAge < Bracket
end
