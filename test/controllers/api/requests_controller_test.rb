require 'test_helper'

class Api::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @existing_request = requests(:fresh)
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
                         last_name: last_name
              })
    assert_response :success
    @existing_request.reload

    assert @existing_request.first_name == first_name
    assert @existing_request.last_name == last_name
    assert @existing_request.client_id == client_id
  end
end
