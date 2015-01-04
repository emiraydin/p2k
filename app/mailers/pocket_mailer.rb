class PocketMailer < ActionMailer::Base
  default from: Settings.DELIVERY_EMAIL_ADDRESS

  def delivery_email(delivery, attachment)
  	@delivery = delivery
  	email_subject = "Your " + @delivery.frequency.titleize + " Delivery From P2K"
  	attachments['p2k.mobi'] = File.read(attachment, mode: "rb")
  	mail(to: @delivery.kindle_email, subject: email_subject)
  	logger.debug "EMAIL SENT! to " + @delivery.kindle_email
  end
end
