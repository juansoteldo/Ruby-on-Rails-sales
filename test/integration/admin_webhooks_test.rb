require 'test_helper'

class AdminWebhooksTest < Capybara::Rails::TestCase
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers

  setup do
    @existing_request = requests(:fresh)
    @webhook = webhooks(:wordpress)
    sign_in salespeople(:active_admin)
  end

  test "index should show fresh webhook" do
    visit admin_webhooks_path
    assert_equal Webhook.uncommitted.count, 1
    assert page.has_content? @webhook.email
  end

  test "re-submit should work" do
    visit admin_webhooks_path
    perform_enqueued_jobs do
      click_on "Re-submit"
      assert_not page.has_content? @webhook.email
    end
    assert @webhook.reload.committed?
  end
end