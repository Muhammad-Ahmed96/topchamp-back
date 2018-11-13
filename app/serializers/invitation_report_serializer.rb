class InvitationReportSerializer < ActiveModel::Serializer
  attributes :invitation_id, :user_id, :participant, :status, :status_name, :attendee_types_names
  def status_name
    unless object.status.nil?
      InvitationStatus.collection[object.status.to_sym]
    end
  end
end
