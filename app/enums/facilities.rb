class Facilities < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Facilities::Indoor < Facilities
end

class Facilities::Outdoor < Facilities
end

class Facilities::Both < Facilities
end