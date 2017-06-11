require 'json'
require 'fileutils'
require 'open-uri'
require 'open_uri_redirections'
require 'kindlerb'
require 'nokogiri'

module CreateBook

	# Create book files necessary for kindlerb
	def self.create_files(articles, username)
	  	current_time = Time.now.strftime("%d%m%Y%H%M")
	  	name = current_time + "_" + username

	  	# Create folder for the book
	  	book_root = ::Rails.root.join('public', 'generated', name)
	  	FileUtils.mkdir_p(book_root)

	  	#Create _document.yml
	  	image = ::Rails.root.join('app', 'assets', 'images', 'p2k-masthead.jpg')
	  	_document = 'doc_uuid: p2k.' + current_time + "\n" +
	  	'title: Your P2K Articles' + "\n" +
	  	'author: p2k.co' + "\n" +
	  	'publisher: p2k.co' + "\n" +
	  	'subject: Pocket Articles' + "\n" +
	  	'date: "' + Time.now.strftime("%d-%m-%Y") +'"' + "\n" +
	  	'masthead: ' + image.to_s + "\n" +
	  	'cover: ' + image.to_s + "\n" +
	  	'mobi_outfile: p2k.mobi'
	  	document_path = book_root.join('_document.yml')
	  	File.open(document_path, "w+") do |f|
	  		f.write(_document)
	  	end

		# Create folder for the images
		images = book_root.join('img')
		FileUtils.mkdir_p(images)

		# Create folder for sections
		sections = book_root.join('sections')
		FileUtils.mkdir_p(sections)

		# Create folder for the only section: Home
		articles_home = sections.join('000')
		FileUtils.mkdir_p(articles_home)

		# Create _section.txt which contains the section title
		_section = articles_home.join('_section.txt')
		File.open(_section, "w+") do |f|
			f.write("Home")
		end

		# Create HTML files for the articles
		self.create_articles(articles, articles_home, images)

		# Return the path to the book
		return book_root
	end

	# Create HTML versions of the articles
	def self.create_articles(articles, articles_home, images_home)
		i = 1
		articles.each do |article|
			# Parse each article and then write them to an HTML file
			File.open(articles_home.to_s+"/"+i.to_s+".html", "w") do |f|
				article_html = self.parse_pocket article[1]['resolved_url']
				article_html = self.find_and_download_images(article_html, images_home)
				f.write("<html>" +
					"<head>" +
					'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' +
					"<title>" + article[1]['resolved_title'] + "</title>" +
					"</head>" +
					"<body>" +
					"<h1>" + article[1]['resolved_title'] + "</h1>" +
					article_html.html_safe +
					"</body>" +
					"</html>"
					)
				i += 1
			end
		end
	end

	# Parse the articles via Pocket Article API (Private Beta)
	def self.parse_pocket(url)
		begin
			response = RestClient.get 'http://text.getpocket.com/v3/text', {:params => {
				:url => url, :consumer_key => Settings.POCKET_CONSUMER_KEY,
				:images => 1, :output => "json"
				}}
		rescue => e
			Rails.logger.debug "Pocket Article View API failed! Switching to Mercury...\n"
			return self.parse_mercury(url, e.message)
		end
		parsed = JSON.parse(response)

		# If there is an error in the response, switch to Mercury API
		if parsed['responseCode'] != "200"
			return self.parse_mercury(url, parsed['excerpt'])
		else
			return parsed['article']
		end
	end

	# Parse the articles via Mercury API
	def self.parse_mercury(url, error)
		begin
			response = RestClient.get 'https://mercury.postlight.com/parser', {
				:params => {
					:url => url
				},
				:'x-api-key' => Settings.MERCURY_PARSER_KEY
			}
		rescue => e
			Rails.logger.debug "Both APIs failed on URL: " + url + "\n"
			return "This article could not be fetched or is otherwise invalid.\n" + 
				"This is most likely an issue with fetching the article from the source server.\n" +
				"URL: " + url + "\n" +
				"Parsing was first tried via Diffbot API. Error message:\n" + error + "\n" +
				"Parsing then tried via Mercury API. Error message:\n" + e.message
		end
		parsed = JSON.parse(response)
		return parsed['content']
	end

	# Parse the articles via Diffbot API
	def self.parse_diffbot(url)
		begin
			response = RestClient.get 'https://api.diffbot.com/v3/article', {:params => {
				:url => url, :token => Settings.DIFFBOT_API_KEY
				}}
		rescue => e
			Rails.logger.debug "Diffbot API failed! Switching to Mercury...\n"
			return self.parse_mercury(url, e.message)
		end
		parsed = JSON.parse(response)

		# If there is an error in the response, switch to Mercury API
		if parsed['error']
			return self.parse_mercury(url, parsed['error'])
		else
			return parsed['objects'][0]['html']
		end
	end

	# Find, download and replace paths of images in the created book to enable local access
	def self.find_and_download_images(html, save_to)

	  	# Find all images in a given HTML
	  	Nokogiri::HTML(html).xpath("//img/@src").each do |src|
	  		begin
		  		src = src.to_s
		  		# Make image name SHA1 hash (only alphanumeric chars) and its extension .jpg
		  		image_name = Digest::SHA1.hexdigest(src) << '.jpg'

		  		# Download image
		  		image_url = save_to.join(image_name).to_s
		  		image_from_src = open(src, :allow_redirections => :safe).read
		  		open(image_url, 'wb') do |file|	  			
	  				file << image_from_src
		  		end

			  	# Resize and make it greyscale
			  	command = 'convert ' + image_url + ' -compose over -background white -flatten -resize "400x267>" -alpha off -colorspace Gray ' + image_url
			  	created = system command

			  	# Replace the image URL with downloaded local version
			  	html = html.gsub(src, "../../img/" + image_name)
			rescue => e
  				# If the image URL cannot be fetched, print an error message
  				puts "IMAGE CANNOT BE DOWNLOADED!: " + e.message + "\n Image URL: " + src
  				next
  			end
		end

	  	# Return the new html
	  	return html
	end

end
