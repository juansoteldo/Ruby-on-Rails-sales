require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @image_file = file_fixture_copy("test.jpg")
    User.all.each(&:destroy!)
  end

  test "webhook call should create request using job" do
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params
      assert_response :success
    end

    assert_not_nil Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
  end

  test "webhook call should create request with positive opt_in" do
    params = wpcf7_params
    params[:user_attributes][:marketing_opt_in] = "1"
    assert_emails(1) do
      perform_enqueued_jobs do
        post "/webhooks/requests_create", params: params
        assert_response :success
      end
    end
    user = User.find(Request.joins(:user).where(users: { email: params[:email] }).first.user_id)
    assert_not_nil user
    assert user.marketing_opt_in.nil? # nil because they have to set truthy using opt-in link
  end

  test "webhook call should create request with negative opt_in" do
    params = wpcf7_params
    params[:user_attributes][:marketing_opt_in] = "0"
    assert_emails(0) do
      perform_enqueued_jobs do
        post "/webhooks/requests_create", params: params
        assert_response :success
      end
    end
    user = User.find(Request.joins(:user).where(users: { email: params[:email] }).first.user_id)
    assert_equal user.marketing_opt_in, false
  end

  test "webhook call should create request with an attached image" do
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params.merge(art_sample_1: @image_file)
      assert_response :success
    end

    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert request.images.count == 1
    assert request.images.first.decorate.exists?
  end

  test "shopify webhook should update its corresponding request" do
    stamp = Time.now
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params
      assert_response :success
    end
    request = Request.where("updated_at > ?", stamp).first
    perform_enqueued_jobs do
      post "/webhooks/orders_create", params: shopify_params.merge(
        "email": wpcf7_params[:email],
        "note_attributes": [
          {
            "name": "req_id",
            "value": request.id.to_s,
          },
          {
            "name": "sales_id",
            "value": request.quoted_by_id,
          },
        ]
      )
    end

    request.reload
    assert request.deposit_order_id == shopify_params["id"].to_s
    assert request.state == "deposited"
  end

  test "shopify webhook should update using email only" do
    stamp = Time.now
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params
      assert_response :success
    end
    request = Request.where("updated_at > ?", stamp).first
    perform_enqueued_jobs do
      post "/webhooks/orders_create", params: shopify_params.merge(
          "email": wpcf7_params[:email],
          "note_attributes": []
      )
    end

    request.reload
    assert request.deposit_order_id == shopify_params["id"].to_s
    assert request.state == "deposited"
  end

  test "shopify webhook should fail to update on mismatch" do
    stamp = Time.now
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: wpcf7_params
      assert_response :success
    end
    request = Request.where("updated_at > ?", stamp).first
    perform_enqueued_jobs do
      params = shopify_params
      params[:email] = SecureRandom.base64(8)
      params[:note_attributes] = []
      post "/webhooks/orders_create", params: params
    end

    request.reload
    assert request.deposit_order_id == shopify_params["id"].to_s
    assert request.state == "deposited"
  end
end
