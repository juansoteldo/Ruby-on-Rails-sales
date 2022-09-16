require "test_helper"

class Api::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @existing_request = requests(:fresh)
    @deposited_request = requests(:deposited)
    @image_file = file_fixture_copy("test.jpg")
    @request_with_image = request_with_image(@image_file)
  end
  test "should not show requests without token" do
    get api_requests_path
    assert_response 401
  end

  test "should show all requests with token" do
    get api_requests_path, params: { token: Settings.ctd.global_api_token }
    assert_response :success
    result = JSON.parse(@response.body)
    assert result.count == 1
  end

  test "should show request with uuid" do
    get api_request_path(@request_with_image.id, uuid: @request_with_image.uuid)
    assert_response :success
  end

  test "should show request with global token" do
    get api_request_path(@request_with_image.id, token: Settings.ctd.global_api_token)
    assert_response :success
  end

  test "should fail to show request without uuid or token" do
    get api_request_path(@request_with_image.id)
    assert_response :not_found
  end

  test "should update request" do
    client_id = SecureRandom.base64
    first_name = SecureRandom.base64
    last_name = SecureRandom.base64
    patch api_request_path(
      @existing_request.id,
      uuid: @existing_request.uuid,
      request: { client_id: client_id,
                 first_name: first_name,
                 last_name: last_name }
    )
    assert_response :success
    @existing_request.reload

    assert @existing_request.first_name == first_name
    assert @existing_request.last_name == last_name
    assert @existing_request.client_id == client_id
  end
end
