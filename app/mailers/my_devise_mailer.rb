class MyDeviseMailer < Devise::Mailer
  layout 'mailer'
  def reset_password_instructions(record, token, opts={})
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    #attachments.inline['footer.png'] = File.read('app/assets/images/footer.png')
    super(record ,record.reset_password_token ,opts)
  end

  def confirmation_instructions(record, token, opts={})
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
    #attachments.inline['footer.png'] = File.read('app/assets/images/footer.png')
    super(record ,token ,opts)
  end
end
