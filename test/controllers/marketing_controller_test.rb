require 'faker'
require 'test_helper'

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
      # NOTE: when using test fixtures 'after_create_commit' doesn't get called so we need to call 'add_user_to_all_list'
      @user.email = Faker::Internet.email
      CampaignMonitorActionJob.perform_now(user: @user, method: "add_user_to_all_list")
      @user.update! presales_opt_in: true, marketing_opt_in: true, crm_opt_in: true
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
    
      assert_equal 200, response.code
      parsed_response = parse_response(response)
      assert_equal 'Unsubscribed', parsed_response[:State]
    end
  end
end
