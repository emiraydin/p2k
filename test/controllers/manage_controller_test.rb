require 'test_helper'

class ManageControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get stop" do
    get :stop
    assert_response :success
  end

end
