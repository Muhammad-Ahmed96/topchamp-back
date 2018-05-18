class Days < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Days::Monday < Days
end

class Days::Tesday < Days
end
class Days::Wesnesday < Days
end
class Days::Thursday < Days
end
class Days::Friday < Days
end
class Days::Saturday < Days
end
class Days::Sunday < Days
end
