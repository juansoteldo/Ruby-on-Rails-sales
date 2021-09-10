require "test_helper"

class MarketingControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    request = requests(:fresh)
    @user = request.user
  end

  test "authentication" do
    get marketing_opt_in_url(user_email: @user.email,
                             user_token: SecureRandom.base64(8))
    assert_response 302
  end

  test "opt_in" do
    @user.update! opted_out: true
    assert_not @user.marketing_opt_in
    assert_not @user.presales_opt_in

    get marketing_opt_in_url(user_email: @user.email,
                             user_token: @user.authentication_token)
    assert_redirected_to edit_email_preference_path(@user, user_email: @user.email,
                                                           user_token: @user.authentication_token)
    @user.reload
    assert @user.marketing_opt_in
    assert @user.presales_opt_in
  end

  test "opt_out" do
    perform_enqueued_jobs do
      @user.update! opted_out: false
      assert @user.marketing_opt_in
      assert @user.presales_opt_in

      get marketing_opt_out_url(user_email: @user.email,
                                user_token: @user.authentication_token)
      assert_redirected_to edit_email_preference_path(@user, user_email: @user.email,
                                                             user_token: @user.authentication_token)
      @user.reload
      assert_not @user.marketing_opt_in
      assert_not @user.presales_opt_in

      sleep 5

      response = Services::CampaignMonitor.get_subscriber_details_in_all(@user)
    
      assert_equal response.code, 200
      assert_equal response.parsed_response['State'], 'Unsubscribed'
    end
  end
end
