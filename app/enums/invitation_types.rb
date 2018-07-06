class InvitationTypes  < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.to_sym] = item.text
    end
    items
  end
end
class InvitationTypes::Event < InvitationTypes
end

class InvitationTypes::Date < InvitationTypes
end

class InvitationTypes::SingUp < InvitationTypes
end

class InvitationTypes::PartnerDouble < InvitationTypes
end

class InvitationTypes::PartnerMixed < InvitationTypes
end