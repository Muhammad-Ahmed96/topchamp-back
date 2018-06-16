class InvitationMailer < ApplicationMailer
  def event(invitation)
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    title = invitation.event.present? ? invitation.event.title : "TopChamp"
    mail(to: invitation.email, subject: "You are invited to #{title}!")
    invitation.send_at = Time.now
    invitation.save!
  end

  def date(invitation)
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    title = invitation.event.present? ? invitation.event.title : "TopChamp"
    mail(to: invitation.email, subject: "Save The Date for #{title}!")
    invitation.send_at = Time.now
    invitation.save!
  end

  def sing_up(invitation)
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    title = invitation.event.present? ? invitation.event.title : "TopChamp"
    mail(to: invitation.email, subject: "You are invited to #{title}!")
    invitation.send_at = Time.now
    invitation.save!
  end
end
