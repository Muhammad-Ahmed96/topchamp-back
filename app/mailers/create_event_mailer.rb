class CreateEventMailer < ApplicationMailer
  def on_create(event, user)
    @event  = event
    @user  = user
    @url =  Rails.configuration.front_login
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    mail(to: user.email, subject: "New event created")
  end
end
