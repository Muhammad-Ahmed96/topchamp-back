class Status < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.text] = item.to_sym
    end
    items
  end

end

class Status::Active < Status
end

class Status::Inactive < Status
end