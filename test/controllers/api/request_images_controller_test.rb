require "test_helper"

class Api::RequestImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image_path = file_fixture_copy("test.jpg")
    @test_request = request_with_image(@image_path)
  end

  test "should show image for request" do
    get api_request_image_path(@test_request.images.first.id, uuid: @test_request.uuid)
    assert_response 200
  end

  test "should show image for using global token" do
    get api_request_image_path(@test_request.images.first.id,
                               token: Rails.application.credentials[:global_api_token])
    assert_response 200
  end

  test "should show image gotten via request api" do
    get api_request_path(@test_request.id, uuid: @test_request.uuid)
    request = JSON.parse(@response.body)
    get request["images"].first["url"]
    assert_response 200
    assert_equal @response.content_type, content_type(@image_path)
  end
end
