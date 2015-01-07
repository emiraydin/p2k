class WelcomeController < ApplicationController

  include PocketClient

  def connect
  	response = PocketClient.get_request_token
  	session[:request_token] = response[:code]
	auth_url = response[:auth_url]
	redirect_to auth_url
  end

  def home
  	# Get all articles from Pocket
  	response = PocketClient.get_access_token(session[:request_token])
	session[:username] = response['username']
	session[:access_token] = response['access_token']

	user = User.where(:username => session[:username]).first

	# If the user is not new and has a delivery set up, update their access token
	# And redirect them to "Manage deliveries" page
	if (not user.nil? and not user.delivery.nil?)
		user.access_token = session[:access_token]
		user.save
		redirect_to "/manage/home"
	else
		# If the user is new, create an account, otherwise just update the access token
		if (user.nil?)
			User.create(:username => session[:username], :access_token => session[:access_token])
		else
			user.access_token = session[:access_token]
			user.save
		end
		redirect_to "/deliveries/home"
	end

  end


end
