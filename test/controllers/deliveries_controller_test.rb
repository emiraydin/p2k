require 'test_helper'

class DeliveriesControllerTest < ActionController::TestCase

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
