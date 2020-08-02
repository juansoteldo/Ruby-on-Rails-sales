require "test_helper"

class EmailPreferencesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    request = requests(:fresh)
    @user = request.user
  end

  test "authentication" do
    get edit_email_preference_url(@user)
    assert_redirected_to new_user_session_path
  end

  test "works with tokens" do
    get edit_email_preference_url(@user,
                                  user_email: @user.email,
                                  user_token: @user.authentication_token)
    assert_response :success
  end

  test "update" do
    @user.update marketing_opt_in: nil
    patch email_preference_url(@user,
                               user_email: @user.email,
                               user_token: @user.authentication_token,
                               params: {
                                 user: { id: @user.id, marketing_opt_in: true }
                               })
    assert_redirected_to edit_email_preference_path(@user,
                                                    user_email: @user.email,
                                                    user_token: @user.authentication_token)
    @user.reload
    assert_equal @user.marketing_opt_in, true
    patch email_preference_url(@user,
                               user_email: @user.email,
                               user_token: @user.authentication_token,
                               params: {
                                 user: { id: @user.id, marketing_opt_in: false }
                               })
    @user.reload
    assert_equal @user.marketing_opt_in, false
  end
end
