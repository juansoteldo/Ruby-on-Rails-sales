require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @image_file = file_fixture_copy("test.jpg")
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
    params[:user_attributes] = {
      marketing_opt_in: "1",
    }
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: params
      assert_response :success
    end
    user = Request.joins(:user).where(users: { email: params[:email] }).first&.user
    assert_not_nil user
    assert user.marketing_opt_in
  end

  test "webhook call should create request with negative opt_in" do
    params = wpcf7_params
    params[:user_attributes] = {
      marketing_opt_in: "0",
    }
    perform_enqueued_jobs do
      post "/webhooks/requests_create", params: params
      assert_response :success
    end
    user = Request.joins(:user).where(users: { email: params[:email] }).first&.user
    assert_not_nil user
    assert_not user.marketing_opt_in
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
end
