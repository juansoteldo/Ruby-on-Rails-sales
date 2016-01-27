require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  test "should get new_request" do
    get :new_request
    assert_response :success
  end

end
