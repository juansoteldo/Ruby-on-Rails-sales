require 'test_helper'

class Admin::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @existing_request = requests(:fresh)
    @deposited_request = requests(:deposited)
    @image_file = file_fixture_copy("test.jpg")
    @request_with_image = request_with_image(@image_file)
  end

  teardown do
    File.unlink(@image_file) if File.exist?(@image_file)
  end

  test "should not show requests without token" do
    get admin_requests_path
    assert_response 401
  end
end
