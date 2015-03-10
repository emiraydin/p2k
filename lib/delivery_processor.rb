require 'fileutils'
require 'kindlerb'
include DeliveryOptions
include CreateBook

module DeliveryProcessor

	# Check if there are any deliveries to be processed
	def self.check
		Rails.logger.debug "DELIVERY CHECKED at " + Time.now.to_s + "\n"
		Delivery.all.each do |d|
			time = Time.now.in_time_zone(d.time_zone)
			# If delivery is daily only look for matching hours, otherwise check days as well
			if d.frequency == 'daily'
				if time.hour == d.hour
					self.deliver d
				end
			else # weekly
				if time.hour == d.hour and time.wday == Delivery.days[d.day]
					self.deliver d
				end
			end
		end
	end

	# Process deliveries from start to beginning
	def self.deliver(delivery)

		# Fetch articles based on delivery option i.e. list, timed, random
		list = DeliveryOptions.method(delivery.option).call(delivery.user.access_token, delivery.count, delivery.archive_delivered)

		# Create file tree from Pocket articles
		book_root = CreateBook.create_files(list, delivery.user.username)

		# Create the ebook
		Dir.chdir(book_root)
		created = Kindlerb.run book_root

		# If the system call returns anything other than nil, the call was successful
		successful = $?.exitstatus.nil? ? false : true

		# Email the ebook
		if successful
			Rails.logger.debug "BOOK CREATED SUCCESSFULLY!\n"
			attachment = book_root.join("p2k.mobi")
			MandrillMailer.send_email(delivery, attachment)
		else
			Rails.logger.debug "ERROR: BOOK COULD NOT BE CREATED!\n"
		end

		# Delete the ebook
		# FileUtils.rm_rf(book_root)

		delivery_log = "----------------\n" +
					   "DELIVERY PROCESSED!\n" +
					   "Recipient: " + delivery.user.username + "\n" +
					   "Kindle Email: " + delivery.kindle_email + "\n" +
					   "Delivery created at " + Time.now.to_s + "\n" +
					   "----------------\n"
		Rails.logger.debug delivery_log

	end

end
