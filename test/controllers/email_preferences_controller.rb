require 'test_helper'

class EmailPreferencesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    request = requests(:fresh)
    @user = request.user
  end

  test "authentication" do
    get edit_email_preferences_url(@user)
    assert_redirected_to new_user_session_path
  end

  test "works with tokens" do
    get edit_email_preferences_url(@user,
                             user_email: @user.email,
                             user_token: @user.authentication_token)
    assert_response :success
  end

  test "opt_out" do
    patch email_preferences_url(@user,
                                   user_email: @user.email,
                                   user_token: @user.authentication_token)
    assert_redirected_to edit_email_preference_path(@user)
  end

end
