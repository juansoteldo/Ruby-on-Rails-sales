require 'test_helper'

class MarketingControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    request = requests(:fresh)
    @user = request.user
  end

  test "authentication" do
    get marketing_opt_in_url(@user)
    assert_redirected_to new_user_session_path
  end

  test "opt_in" do
    @user.update opted_out: true
    assert_not @user.marketing_opt_in
    assert_not @user.presales_opt_in
    get marketing_opt_in_url(@user,
                              user_email: @user.email,
                              user_token: @user.authentication_token)
    assert_redirected_to edit_email_preference_path(@user)
    @user.reload
    assert @user.marketing_opt_in
    assert @user.presales_opt_in
  end

  test "opt_out" do
    @user.update opted_out: false
    assert @user.marketing_opt_in
    assert @user.presales_opt_in
    get marketing_opt_out_url(@user,
                             user_email: @user.email,
                             user_token: @user.authentication_token)
    assert_redirected_to edit_email_preference_path(@user)
    @user.reload
    assert_not @user.marketing_opt_in
    assert_not @user.presales_opt_in
  end

end
