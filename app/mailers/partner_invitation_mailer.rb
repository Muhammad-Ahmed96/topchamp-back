class PartnerInvitationMailer < ApplicationMailer
  def double(player, partner)
    @partner = partner
    @player  =  player
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
  end

  def mixed(player, partner)
    @partner = partner
    @player  =  player
    attachments.inline['top-logo.png'] = File.read('app/assets/images/top-logo.png')
  end
end
