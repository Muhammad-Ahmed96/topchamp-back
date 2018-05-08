class MyDeviseMailer < Devise::Mailer
  def reset_password_instructions(record, token, opts={})
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    attachments.inline['footer.png'] = File.read('app/assets/images/footer.png')
    super(record ,token ,opts)
  end
end
