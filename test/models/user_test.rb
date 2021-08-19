require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
  end

  teardown do
  end

  test "check subscribe user to CM" do
    email = SecureRandom.hex(8);
    perform_enqueued_jobs do
      user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
      sleep 15

      response = Services::CampaignMonitor.get_subscriber_details_in_all(user)
      assert_equal response.code, 200
      assert_equal response.parsed_response['State'], 'Active'

      response = Services::CampaignMonitor.get_subscriber_details_in_marketing(user)
      assert_equal response.code, 200
      assert_equal response.parsed_response['State'], 'Unconfirmed'

      # delete subscriber
      response = Services::CampaignMonitor.delete_subscriber(user)
      assert_equal response.code, 200
    end
  end
end
