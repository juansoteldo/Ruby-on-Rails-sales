require 'test_helper'
# require 'string_utils'

class CampaignMonitorJobTest < ActiveJob::TestCase

  attr_accessor :user
  attr_accessor :list_id

  def parse_response(response)
    JSON.parse(response, symbolize_names: true)
  end

  setup do
    email = SecureRandom.hex(8);
    @user = User.create(email: "#{email}@test.com", marketing_opt_in: true)
    @request = Request.create(user: @user)
    # Create a temporary list for testing purposes
    list_title = "temp_list_#{Time.now.to_i}"
    response = CampaignMonitorActionJob.perform_now(method: 'create_list', list_title: list_title)
    @list_id = parse_response(response)
    assert_not_nil @list_id
  end

  teardown do
    # Delete temporary list
    response = CampaignMonitorActionJob.perform_now(method: 'delete_list', list_id: @list_id)
    assert_equal 200, response.code
  end

  test 'create/read/update/delete subscribers' do
    response = CampaignMonitorActionJob.perform_now(method: 'add_user_to_list', list_id: @list_id, user: @user)
    assert_equal 201, response.code

    sleep 5

    response = CampaignMonitorActionJob.perform_now(method: 'get_subscriber_details_from_list', list_id: @list_id, user: @user)
    assert_equal 200, response.code

    response = CampaignMonitorActionJob.perform_now(method: 'update_user_to_list', list_id: @list_id, user: @user)
    assert_equal 200, response.code

    response = CampaignMonitorActionJob.perform_now(method: 'delete_subscriber_from_list', list_id: @list_id, user: @user)
    assert_equal 200, response.code
  end

  test 'send transactional email' do
    smart_email_id = TransactionalEmail.find_by(name: 'test').smart_id
    response = CampaignMonitorActionJob.perform_now(method: 'send_transactional_email', smart_email_id: smart_email_id, user: @user)
    assert_equal 202, response.code
  end

  test 'newsletter route' do
    params = {
      name: @user.first_name,
      email: @user.email
    }
    response = CampaignMonitorActionJob.perform_now(user: { user: params }, method: "add_email_to_marketing_list")
    assert_equal response.code, 201
  end

  # TODO:
  #       - verify custom fields get updated
  #       - verify remove subscriber

end
