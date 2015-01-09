include PocketClient

module DeliveryOptions

	# Returns #count latest articles
	def self.latest(access_token, count, archive)
		articles = PocketClient.get_articles(access_token, count)
		# Archive delivered if requested
		if archive
			PocketClient.archive_articles(access_token, articles)
		end
		return articles
	end

	# Returns bunch of articles worth #count minutes
	def self.timed(access_token, count, archive)
		# Get all the articles
		articles = PocketClient.get_articles(access_token, "")

		# Create a resulting set and a time tracker
		result = Array.new
		total_time = 0

		# Add articles to the resulting set until the time limit is reached
		articles.each do |a|
			# Find out article's read time and add if the total is not reached
			a_time = self.read_time(a[1]['word_count'])
			if a_time + total_time <= count
				result.push(a)
				total_time += a_time
			else
				# If the resulting set is empty, move on to the next article
				if result.empty?
					next
				else
				# Otherwise, stop adding
					break
				end
			end
		end

		# Archive delivered if requested
		if archive
			PocketClient.archive_articles(access_token, result)
		end

		return result

	end

	# Returns #count random articles
	def self.random(access_token, count, archive)
		# Get all articles and choose randomly among them
		articles = PocketClient.get_articles(access_token, "")

		result = Hash[articles.to_a.sample(count)]

		# Archive delivered if requested
		if archive
			PocketClient.archive_articles(access_token, result)
		end

		return result
	end

	# Find the read time in minutes using average WPM of 250
	def self.read_time(word_count)
		avg_wpm = 250.0
		result = word_count.to_f / avg_wpm
		return result.ceil
	end

end