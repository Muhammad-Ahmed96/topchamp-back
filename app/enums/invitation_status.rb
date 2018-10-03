class InvitationStatus < ClassyEnum::Base
  # Collection for formtastic
  def self.collection
    items = {}
    all.each do |item|
      items[item.to_sym] = item.text
    end
    items
  end
end


class InvitationStatus::PendingConfirmation < InvitationStatus
end

class InvitationStatus::Accepted < InvitationStatus
end

class InvitationStatus::Declined < InvitationStatus
end