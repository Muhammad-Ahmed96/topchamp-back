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


class InvitationStatus::PendingInvitation < InvitationStatus
end

class InvitationStatus::Role < InvitationStatus
end

class InvitationStatus::Refuse < InvitationStatus
end