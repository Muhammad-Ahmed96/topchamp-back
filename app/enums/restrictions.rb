class Restrictions < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Restrictions::None < Restrictions
end

class Restrictions::NoPets < Restrictions
end
class Restrictions::NoGrilling < Restrictions
end
class Restrictions::NoSmoking < Restrictions
end
class Restrictions::NoOutsideFoodOrBeverage < Restrictions
end
class Restrictions::NoGlassware < Restrictions
end
class Restrictions::NoOutdoorFires < Restrictions
end