class DeliveriesController < ApplicationController

  include DeliveryProcessor

  def destroy
    # Destroy the delivery
    @delivery = Delivery.find(params[:id])
    @delivery.destroy
    # Add a flash and redirect to homepage
    flash[:notice] = "You have successfully stopped all your deliveries."
    redirect_to :controller => "welcome", :action => "index"
  end

  def create
    # Find the user
    user = User.where(:username => session[:username]).first

    # Figure out the appropriate count for delivery option
    option_map = {'latest' => process_params[:count_latest], 'timed' => process_params[:count_timed], 'random' => process_params[:count_random]}
    count = option_map[process_params[:option]]

    # Parse the time provided by the user and convert it to hour with time zone processed
    # time_zone = ActiveSupport::TimeZone.new(d_params[:time_zone])
    hour = process_params["time(4i)"]
    # Update params
    new_params = delivery_params.merge(hour: hour, count: count, user: user)

    # If the user exists, create a new delivery or update existing
    if (user.delivery.nil?)
      @delivery = Delivery.new(new_params)
    else
      @delivery = user.delivery
      @delivery.assign_attributes(new_params)
    end

    # If the delivery is successfully saved, create a notice and redirect to user home
    if @delivery.save
      flash[:notice] = "You have successfully created a new delivery."
      redirect_to :controller => "manage", :action => "home"
    end

  end

  def onetime_delivery
    # Figure out the appropriate count for delivery option
    option_map = {'latest' => onetime_params[:count_latest], 'timed' => onetime_params[:count_timed], 'random' => onetime_params[:count_random]}

    # Create a new delivery but don't save it to the database
    delivery = Delivery.new
    delivery.user = User.where(:username => session[:username]).first
    delivery.kindle_email = onetime_params[:kindle_email]
    delivery.option = onetime_params[:option]
    delivery.count = option_map[onetime_params[:option]]
    delivery.archive_delivered = onetime_params[:archive_delivered]

    # Process the delivery right away
    DeliveryProcessor.deliver(delivery)
    # Set the flash notice and redirect
    flash[:notice] = "Your one-time delivery has been successfully completed."
    redirect_to :controller => "deliveries", :action => "onetime"

  end

  private
  def delivery_params
    params.require(:delivery).permit(:frequency, :day, :time_zone, :option, :archive_delivered, :kindle_email)
  end

  def process_params
    params.require(:delivery).permit(:option, :time, :count_latest, :count_timed, :count_random)
  end

  def parse_time(hash)
    return Time.parse("#{hash['time(1i)']}-#{hash['time(2i)']}-#{hash['time(3i)']} #{hash['time(4i)']}:#{hash['time(5i)']}")
  end

  def onetime_params
    params.require(:delivery).permit(:option, :count_latest, :count_timed, :count_random, :kindle_email, :archive_delivered)    
  end

end
