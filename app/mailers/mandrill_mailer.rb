class MandrillMailer

	require 'mandrill'
	require 'base64'

	def self.send_email(delivery, attachment)
	  	# Use Mandrill API to send an email first, if it fails use SMTP
	  	emailMessage = "Hi #{delivery.user.username}, here is your #{delivery.frequency} delivery from P2K."
	  	begin
			m = Mandrill::API.new Settings.MANDRILL_API_KEY
			message = {  
			 :subject => "Your Delivery From P2K",  
			 :from_email => Settings.DELIVERY_EMAIL_ADDRESS,
			 :from_name => "P2K",   
			 :to => [  
			   {  
			     :email=> delivery.kindle_email,  
			     :name => "P2K User"  
			   }  
			 ], 
			 :text => emailMessage,
			 :html => emailMessage,
			 :attachments => [{
			 	:name => "p2k.mobi",
			 	:type => "application/x-mobipocket-ebook",
			 	:content => Base64.encode64(File.read(attachment, mode: "rb"))
			 	}]
			}
			result = m.messages.send message
			
			# If the email is not rejected or invalid, it's either sent or queued or scheduled
			if (result[0][:status] != 'rejected' && result[0][:status] != 'invalid')
	  			Rails.logger.debug "EMAIL SENT! to " + delivery.kindle_email + " via Mandrill" 	
	  		else
	  			# Send using SMTP
	  			Rails.logger.debug "Mandrill returned status != sent, switching to SMTP!\n"
	  			PocketMailer.delivery_email(delivery, attachment)
	  		end
	  	# Rescue from Mandrill errors, and use SMTP if it happens
		rescue Mandrill::Error => e
	    	Rails.logger.debug "A mandrill error occurred: #{e.class} - #{e.message}, switching to SMTP"
	    	PocketMailer.delivery_email(delivery, attachment)
		end
	end

end