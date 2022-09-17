require "test_helper"

class PublicControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @existing_request = requests(:fresh)
    @salesperson = salespeople(:active)
  end

  teardown do
  end

  test "should get new_request" do
    post new_request_path(email: "test@email.com", format: :json)
    assert_response :success
    new_request = JSON.parse(@response.body)
    assert new_request["id"] > 0
    assert new_request["user_id"] > 0
  end

  test "should make only one new_request for multiple posts" do
    post new_request_path(email: "test@email.com", format: :json)
    assert_response :success
    first_id = JSON.parse(@response.body)["id"]
    post new_request_path(email: "test@email.com", format: :json)
    assert_response :success
    assert_equal JSON.parse(@response.body)["id"], first_id
    sleep 2
    post new_request_path(email: "test@email.com", format: :json)
    assert_response :success
    assert_not_equal JSON.parse(@response.body)["id"], first_id
  end

  test "should fail to get new request for invalid email" do
    post new_request_path(email: "user#{SecureRandom.base64}@example....com.", format: :json)
    assert_response :unprocessable_entity
  end

  test "should set first_name on user" do
    post new_request_path(email: "test@email.com", first_name: "John", format: :json)
    assert_response :success
    new_request = JSON.parse(@response.body)
    request = Request.find new_request["id"]
    assert request.first_name == "John"
    assert request.user.first_name == "John"
  end

  test "should get uid based on client id" do
    get get_uid_path(client_id: @existing_request.client_id, format: :json)
    assert_response :success
    body = @response.body
    assert body.to_s != ""
    assert body.to_i.to_s == body
    assert User.exists?(body.to_i)
  end

  test "should not get uid based on missing client id" do
    get get_uid_path(format: :json)
    assert_response :success
    body = @response.body
    assert_not JSON.parse(body)
  end

  test "should get links for existing user" do
    get get_links_path(email: @existing_request.user.email, sales_email: @salesperson.email, format: :json)
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.has_key?("requests") && response["requests"].length > 0
    assert response.has_key?("groups") && response["groups"].length > 0
  end

  test "should get links for new user" do
    get get_links_path(email: "user#{SecureRandom.base64}@example.com", sales_email: @salesperson.email, format: :json)
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.has_key?("groups") && response["groups"].length > 0
  end

  test "should fail to get links without sales email" do
    get get_links_path(email: "user#{SecureRandom.base64}@example.com", format: :json)
    assert_response :bad_request
  end

  test "should fail to get links for invalid email" do
    get get_links_path(email: "user#{SecureRandom.base64}@example....com.", sales_email: @salesperson.email, format: :json)
    assert_response :unprocessable_entity
  end

  test "set_link should assign quotation parameters" do
    settings(:auto_quoting).update! value: false

    variant = Variant.all.first
    request = requests(:fresh)
    get set_link_path(request_id: request.id, variant_id: variant.id, salesperson_id: @salesperson.id, format: :json)
    assert_response :success
    request.reload
    assert request.state == "quoted"
    assert request.quoted_by_id == @salesperson.id
    assert request.variant.to_i == variant.id
  end

  test "should redirect to shopify cart" do
    variant = Variant.all.first
    product = Product.find(variant.product_id)
    get cart_redirect_path(product.handle, variant.id, requestId: @existing_request.id)
    assert_response :success
    assert @response.body.include?(product.handle)
    assert @response.body.include?(variant.id.to_s)
    assert @response.body.include?(@existing_request.client_id)
  end

  test "should fail to get new_request with generic missing parameters" do
    post new_request_path(position: "Chest", gender: "Male", first_name: "John", client_id: "123456", format: :json)
    assert_response 422
  end

  # NOTE: Commented out because it doesn't consistently pass but it should be possible if test is rewritten using a different approach.
  # test "should save email and update streak box stage" do
  #   salesperson = Salesperson.first
  #   user = users(:wpcf7)

  #   delete_boxes_for_email(user.email)

  #   box = MostlyStreak::Box.new_with_name(user.email)
  #   stage_name = MostlyStreak::Stage.find({ key: box.stage_key }).name
  #   assert MostlyStreak::Stage.fresh.name, stage_name

  #   # NOTE: need to wait at least 30 seconds or we won't be able to find a streak box that is newly created
  #   # even with delay, still prone to failure, known testing streak/gmail issue
  #   sleep 30

  #   perform_enqueued_jobs do
  #     get save_email_path(params: { thread_id: nil, recipient_email: box.name, from_email: salesperson.email }, format: :js)
  #     assert_response :success
  #   end
  #   assert_performed_jobs 1

  #   sleep 5

  #   box = Streak::Box.find(box.key)
  #   stage_name = MostlyStreak::Stage.find({ key: box.stage_key }).name
  #   assert_equal MostlyStreak::Stage.contacted.name, stage_name
  # end

  def delete_boxes_for_email(email)
    while box = MostlyStreak::Box.find_by_name(email)
      box.delete
      sleep 2
    end
  end
end
