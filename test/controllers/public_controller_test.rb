require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  test "should get new_request with generic request" do
    get :new_request, { position: "Chest", gender: "Male", first_name: "John", last_name: "Smith", client_id: "123456" }
    assert_response :success
  end

  test "should fail to get new_request with generic missing parameters" do
    get :new_request, { position: "Chest", gender: "Male", first_name: "John", client_id: "123456" }
    assert_response :error
  end

end
