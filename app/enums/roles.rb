class Roles < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Roles::Sysadmin < Roles
end

class Roles::Agent < Roles
end

class Roles::Member < Roles
end

# class Roles::Customer < Roles
# end

class Roles::Director < Roles
end
