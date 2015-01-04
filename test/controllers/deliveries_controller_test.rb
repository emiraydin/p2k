require 'test_helper'

class DeliveryControllerTest < ActionController::TestCase
  test "should get daily" do
    get :daily
    assert_response :success
  end

  test "should get weekly" do
    get :weekly
    assert_response :success
  end

  test "should get onetime" do
    get :onetime
    assert_response :success
  end

end
