class Genders < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Genders::Male < Genders
end

class Genders::Female < Genders
end