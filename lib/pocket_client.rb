require 'rest_client'

module PocketClient

	# Get Pocket request_token that will allow for access_token request
	def self.get_request_token
		response = RestClient.post "https://getpocket.com/v3/oauth/request", { 'consumer_key' => Settings.POCKET_CONSUMER_KEY, 'redirect_uri' => Settings.POCKET_REDIRECT_URI }.to_json, {"Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json"}
		code = JSON.parse(response)['code']
		auth_url = "https://getpocket.com/auth/authorize?request_token=" + code + "&redirect_uri=" + Settings.POCKET_REDIRECT_URI
		return {:code => code, :auth_url => auth_url}
	end

	# Get Pocket access_token for the user via the given request_token
	def self.get_access_token(request_token)
		response = RestClient.post "https://getpocket.com/v3/oauth/authorize", { 'consumer_key' => Settings.POCKET_CONSUMER_KEY, 'code' => request_token }.to_json, {"Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json"}
		# returns both access_token and username
		return JSON.parse(response)
	end

	def self.get_articles(access_token, count)
		response = RestClient.post "https://getpocket.com/v3/get", { 'consumer_key' => Settings.POCKET_CONSUMER_KEY, 'access_token' => access_token, 'count' => count, 'detailType' => 'simple' }.to_json, {"Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json"}
		return JSON.parse(response)['list']
	end

	# Archive Pocket articles with given item IDs
	def self.archive_articles(access_token, articles)
		actions = Array.new
		articles.each do |a|
			actions.push({"action" => "archive", "item_id" => a[1]['item_id']})
		end
		response = RestClient.post "https://getpocket.com/v3/send", :consumer_key => Settings.POCKET_CONSUMER_KEY, :access_token => access_token, :actions => actions.to_json
		archived = JSON.parse(response)['status']
		if archived == 1
			return true
		else
			return false
		end
	end

end