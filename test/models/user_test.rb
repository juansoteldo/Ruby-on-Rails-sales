require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
  end

  teardown do
  end

  test "check unsubscribe user from marketing list" do
    email = SecureRandom.hex(8);
    user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
    sleep 15

    response = Services::CM.get_subscriber_details_in_all(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Active'

    response = Services::CM.get_subscriber_details_in_marketing(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Active'


    user.update(marketing_opt_in: false)
    sleep 15 
 
    response = Services::CM.get_subscriber_details_in_all(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Active'

    response = Services::CM.get_subscriber_details_in_marketing(user)
    assert_equal response.code, 200
    assert_equal response.parsed_response['State'], 'Unsubscribed'

    # delete subscriber
    response = Services::CM.delete_subscriber(user)
    assert_equal response.code, 200
  end

end
