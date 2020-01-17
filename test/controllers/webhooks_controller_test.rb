require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    Request.skip_creating_streak_boxes = true
    change_delivery_method_to :test
    @image_file = file_fixture_copy("test.jpg")
  end

  teardown do
    Request.skip_creating_streak_boxes = false
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
    assert_enqueued_emails(1) do
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
    assert_enqueued_emails(0) do
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

  test "webhook call should send start design email" do
    Request.skip_creating_streak_boxes = false
    @user = User.where(email: wpcf7_params[:email]).first
    perform_enqueued_jobs(only: RequestCreateJob) do
      post "/webhooks/requests_create", params: wpcf7_params.merge(art_sample_1: @image_file)
      assert_response :success
    end
    assert_enqueued_emails(2)
    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert_not_nil MostlyStreak::Box.find(request.streak_box_key)
  rescue
    Request.skip_creating_streak_boxes = true
    raise
  end
end
