require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
  end

  teardown do
  end

  test 'phone number validation' do
    user = users(:one)
    user.phone_number = '+9117867900700'
    assert user.valid?
    user.phone_number = '++9117867900700'
    assert user.invalid?
    user.phone_number = 'abc'
    assert user.invalid?
    user.phone_number = ''
    assert user.valid?
  end

  test 'check subscribe user to CM' do
    email = SecureRandom.hex(8);
    perform_enqueued_jobs do
      user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
      sleep 15

      response = Services::CampaignMonitor.get_subscriber_details_in_all(user)
      parsed_response = parse_response(response)
      assert_equal 200, response.code
      assert_equal 'Active', parsed_response[:State]

      response = Services::CampaignMonitor.get_subscriber_details_in_marketing(user)
      parsed_response = parse_response(response)
      assert_equal 200, response.code
      assert_equal 'Unconfirmed', parsed_response[:State]

      # delete subscriber
      response = Services::CampaignMonitor.delete_subscriber(user)
      assert_equal 200, response.code
    end
  end
end
