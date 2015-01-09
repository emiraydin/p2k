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
				article_html = self.parse article[1]['resolved_url']
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


	# Parse the articles via Readability API
	def self.parse(url)
		begin
			response = RestClient.get 'https://readability.com/api/content/v1/parser', {:params => {
				:url => url, :token => Settings.READABILITY_PARSER_KEY
				}}
			rescue => e
				return "This article could not be fetched or is otherwise invalid.\n" + 
				"This is most likely an issue with fetching the article from the source server.\n" +
				"Please check that the source server is available and that your URL was properly escaped.\n" +
				"URL: " + url + "\n"
		end
		parsed = JSON.parse(response)
		return parsed['content']
	end

	# Find, download and replace paths of images in the created book to enable local access
	def self.find_and_download_images(html, save_to)

	  	# Find all images in a given HTML
	  	Nokogiri::HTML(html).xpath("//img/@src").each do |src|
	  		src = src.to_s
	  		name = src.split("/")
	  		# Windows doesn't accept * or ? in file names
	  		name = name[name.size-1].split("?")[0]
	  		name = name.gsub('*', '')

	  		# Download image
	  		image_url = save_to.join(name).to_s
	  		open(image_url, 'wb') do |file|
	  			begin
	  				file << open(src, :allow_redirections => :safe).read
				rescue => e
	  				# If the image URL cannot be fetched, print an error message and continue
	  				puts "IMAGE CANNOT BE FETCHED!: " + e.message
	  				next
	  			end
	  		end
		  	

		  	# Convert to JPG
		  	new_image = image_url.split(".")
		  	ext = new_image[new_image.size-1]
		  	new_image[new_image.size-1] = ".jpg"
		  	new_image_url = new_image.join

		  	# Resize and make it greyscale
		  	command = 'convert ' + image_url + ' -compose over -background white -flatten -resize "400x267>" -alpha off -colorspace Gray ' + new_image_url
		  	created = system command
	  		# Remove the old image
	  		if created and ext != "jpg"
	  			FileUtils.rm(image_url)
	  		end
		  	# Replace the image URL with downloaded local version
		  	new_image_name = new_image_url.split("/")
		  	new_image_name = new_image_name[new_image_name.size-1]
		  	html = html.gsub(src, "../../img/" + new_image_name)
		  end
	  	# Return the new html
	  	return html
	end

end