class Visibility < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Visibility::Private < Visibility
end

class Visibility::Public < Visibility
end