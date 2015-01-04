class ManageController < ApplicationController

  def home
    @user = User.where(:username => session[:username]).first
  	# Redirect user back if it does not exist
  	if (@user.nil?)
  		redirect_to "/deliveries/home"
  	end	
    @delivery = @user.delivery


  end

  def stop
    @delivery = User.where(:username => session[:username]).first.delivery
    # Redirect user back if it does not exist
    if (@delivery.nil?)
      redirect_to "/deliveries/home"
    end
  end

end
