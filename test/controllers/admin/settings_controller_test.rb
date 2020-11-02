require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "allow change of auto-quoting setting to salespeople" do
    sign_in salespeople(:active)
    Setting.auto_quoting.update! value: false
    patch admin_setting_path(Setting.auto_quoting, params: { setting: { value: true } }, format: :json)
    assert_response 200
    assert Setting.auto_quoting.reload.value == true
  end
end
