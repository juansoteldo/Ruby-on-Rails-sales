require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    RequestMailer.delivery_method = :test
    @image_file = file_fixture_copy("test.jpg")
    @image_url = "https://wiki.customtattoodesign.ca/templates/graphic-layovers/male/male_-_arm_1_-_left.jpg"
  end

  teardown do
  end

  def generate_request
    request = requests(:wpcf7)
    request.ensure_streak_box
    request.opt_in_user
    request
  end

  def last_request_after(stamp, email: wpcf7_params[:email])
    Request.joins(:user).where("requests.updated_at > ? AND email = ?", stamp, email).last
  end

  test "webhook call should create request using job" do
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params
      assert_response :success
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert webhook.committed?

    assert_not_nil Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
  end

  test "webhook call should create request with positive opt_in" do
    params = wpcf7_params
    params[:user_attributes][:marketing_opt_in] = true

    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: params, as: :json
      assert_response :success
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state

    user = User.find(Request.joins(:user).where(users: { email: params[:email] }).first.user_id)
    assert_not_nil user
    assert user.marketing_opt_in?
  end

  test "webhook call should create request with negative opt_in" do
    params = wpcf7_params
    params[:user_attributes][:marketing_opt_in] = "0"
    assert_enqueued_emails(0) do
      perform_enqueued_jobs do
        post "/webhooks/requests_create", params: params
        assert_response :success
      end
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state
    user = User.find(Request.joins(:user).where(users: { email: params[:email] }).first.user_id)
    assert_equal user.marketing_opt_in, false
  end

  test "webhook call should create request with an attached image" do
    stamp = Time.now
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params.merge(art_sample_1: @image_file)
      assert_response :success
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state

    request = last_request_after(stamp)
    assert request.images.count == 1
    assert request.images.first.decorate.exists?
  end

  test "webhook call with image url should create request with an attached image" do
    stamp = Time.now
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params.merge(art_sample_1: @image_url)
      assert_response :success
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state

    request = last_request_after(stamp)
    assert request.images.count == 1
    assert request.images.first.decorate.exists?
  end

  test "webhook call with base64 images should create request with an attached images" do
    stamp = Time.now
    @image_data = "data:image/jpg;base64," + Base64.encode64(@image_file.read.to_s)
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params.merge(
        art_sample_1: @image_data
      )
      assert_response :success
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state

    request = last_request_after(stamp)
    assert request.images.count == 1
    assert request.images.first.decorate.exists?
  end

  test "webhook call with mixed format images should add all of them" do
    stamp = Time.now
    @image_data = "data:image/jpg;base64," + Base64.encode64(@image_file.read.to_s)
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params.merge(
        art_sample_1: @image_data,
        art_sample_2: @image_file,
        art_sample_3: @image_url
      )
      assert_response :success
    end
    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state

    request = last_request_after(stamp)
    assert request.images.count == 3
  end

  test "shopify webhook should update its corresponding request" do
    request = generate_request
    perform_enqueued_jobs do
      post "/webhooks/orders_create", params: shopify_params.merge(
        "email": wpcf7_params[:email],
        "note_attributes": [
          {
            "name": "req_id",
            "value": request.id.to_s
          },
          {
            "name": "sales_id",
            "value": request.quoted_by_id
          }
        ]
      ), as: :json
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state
    request.reload
    assert request.deposit_order_id == shopify_params["id"].to_s
    assert request.state == "deposited"
  end

  test "shopify webhook should update using email only" do
    request = generate_request

    perform_enqueued_jobs do
      params = shopify_params.merge(
        "email": wpcf7_params[:email],
        "note_attributes": []
      )
      params["landing_site"].gsub!(/reqid=[\d]+/, "reqid=#{request.id}")
      post "/webhooks/orders_create", params: params, as: :json
    end

    webhook = Webhook.find(response.body.to_i)
    assert_not_equal webhook.tries, 0
    assert_equal "committed", webhook.aasm_state
    request.reload
    assert request.deposit_order_id == shopify_params["id"].to_s
    assert request.state == "deposited"
  end

  # NOTE: disabled for now since landing_site is disabled.
  # test "shopify webhook should update using landing_site url params" do
  #   request = generate_request
  #   email = SecureRandom.base64(8)

  #   perform_enqueued_jobs do
  #     params = shopify_unassociated_params.merge(
  #       "email": email,
  #       "note_attributes": []
  #     )
  #     params["landing_site"].gsub!(/reqid=[\d]+/, "reqid=#{request.id}")
  #     post "/webhooks/orders_create", params: params, as: :json
  #   end

  #   webhook = Webhook.find(response.body.to_i)
  #   assert_not_equal webhook.tries, 0
  #   assert_equal "committed", webhook.aasm_state
  #   assert request.reload.deposit_order_id == shopify_unassociated_params["id"].to_s
  #   assert request.state == "deposited"
  # end

  # NOTE: needs to be updated, broken test.
  # test "shopify webhook should fail to update on mismatch" do
  #   request = generate_request
  #   email = SecureRandom.base64(8)

  #   perform_enqueued_jobs do
  #     params = shopify_params
  #     params["email"] = email
  #     params["landing_site"].gsub!(/reqid=[\d]+/, "reqid=123456")
  #     params["note_attributes"] = []
  #     post "/webhooks/orders_create", params: params, as: :json
  #     assert_response :success
  #   end

  #   webhook = Webhook.find(response.body.to_i)
  #   assert_not_equal webhook.tries, 0

  #   assert_not_nil webhook.last_error
  #   assert_equal "failed", webhook.aasm_state
  #   assert_nil request.reload.deposit_order_id
  #   assert request.state == "fresh"
  # end

  test "webhook call should send start design email" do
    Settings.streak.create_boxes = true

    @user = User.where(email: wpcf7_params[:email]).first
    assert_emails(1) do
      perform_enqueued_jobs do
        perform_enqueued_jobs do
          post "/webhooks/requests_create", params: wpcf7_params, as: :json
          assert_response :success
        end
      end
    end

    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert_not_nil MostlyStreak::Box.find(request.streak_box_key)
  end
end
