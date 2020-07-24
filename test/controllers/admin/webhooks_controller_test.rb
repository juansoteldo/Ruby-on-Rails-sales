require "test_helper"

class Admin::WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers

  setup do
    @existing_request = requests(:fresh)
    @admin = salespeople(:active_admin)
    @webhook = webhooks(:wordpress)
    sign_in @admin
  end

  test "index should redirect if not logged in" do
    sign_out @admin
    get admin_webhooks_path
    assert_response 302
  end

  test "index should redirect if not admin" do
    sign_out @admin
    sign_in salespeople(:active)
    get admin_webhooks_path
    assert_response 302
  end
end
