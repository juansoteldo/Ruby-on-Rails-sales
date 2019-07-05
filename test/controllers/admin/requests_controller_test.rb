require 'test_helper'

class Admin::RequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @existing_request = requests(:fresh)
    @deposited_request = requests(:deposited)
    @image_file = file_fixture_copy("test.jpg")
    @request_with_image = request_with_image(@image_file)
  end

  test "should not show requests when not logged in" do
    get admin_requests_path(format: :json)
    assert_response 401
  end

  test "should not show requests when logged in as user" do
    sign_in users(:one)
    get admin_requests_path(format: :json)
    assert_response 401
  end

  test "should not show requests to inactive salesperson" do
    sign_in salespeople(:inactive)
    get admin_requests_path(format: :json)
    assert_response 302
  end

  test "should show requests to active salesperson" do
    sign_in salespeople(:active)
    get admin_requests_path(format: :json)
    assert_response 200
  end

  test "should truncate requests to specified limit" do
    sign_in salespeople(:active)
    get admin_requests_path(limit: 1, format: :json)
    assert_response 200
    object = JSON.parse(@response.body)
    assert_equal 1, object["rows"].length
  end

  test "should proceed to next offset" do
    sign_in salespeople(:active)
    get admin_requests_path(limit: 1, offset: 0, format: :json)
    first_id = JSON.parse(@response.body)["rows"][0]["id"]
    get admin_requests_path(limit: 1, offset: 1, format: :json)
    second_id = JSON.parse(@response.body)["rows"][0]["id"]
    assert_not_equal first_id, second_id
  end
end
