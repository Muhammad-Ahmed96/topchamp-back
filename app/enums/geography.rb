class Geography < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Geography::Local < Geography
end

class Geography::Regional < Geography
end

class Geography::National < Geography
end

class Geography::International < Geography
end