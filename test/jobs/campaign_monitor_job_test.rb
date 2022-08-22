require 'test_helper'
# require 'string_utils'

class CampaignMonitorJobTest < ActiveJob::TestCase

  attr_accessor :user
  attr_accessor :list_id

  def parse_response(response)
    JSON.parse(response, symbolize_names: true)
  end

  setup do
    @request = requests(:quoted)
    @user = @request.user
    # Create a temporary list for testing purposes
    list_title = "temp_list_#{Time.now.to_i}"
    response = CampaignMonitorActionJob.perform_now(method: 'create_list', list_title: list_title)
    @list_id = parse_response(response)
    assert !@list_id.nil?
  end

  teardown do
    # Delete temporary list
    response = CampaignMonitorActionJob.perform_now(method: 'delete_list', list_id: @list_id)
    assert response.code == 200
  end

  test 'create/read/update/delete subscribers' do
    response = CampaignMonitorActionJob.perform_now(method: 'add_user_to_list', list_id: @list_id, user: @user)
    assert response.code == 201

    response = CampaignMonitorActionJob.perform_now(method: 'get_subscriber_details_from_list', list_id: @list_id, user: @user)
    assert response.code == 200

    response = CampaignMonitorActionJob.perform_now(method: 'update_user_to_list', list_id: @list_id, user: @user)
    assert response.code == 200

    response = CampaignMonitorActionJob.perform_now(method: 'delete_subscriber_from_list', list_id: @list_id, user: @user)
    assert response.code == 200
  end

  test 'send transactional email' do
    smart_email_id = Rails.application.credentials.cm[:transactional_emails][:test]
    response = CampaignMonitorActionJob.perform_now(method: 'send_transactional_email', smart_email_id: smart_email_id, user: @user)
    assert response.code == 202
  end

  test 'newsletter route' do
    params = {
      name: @user.first_name,
      email: @user.email
    }
    response = CampaignMonitorActionJob.perform_now(user: { user: params }, method: "add_email_to_marketing_list")
    assert response.code == 201
  end

  # TODO:
  #       - verify custom fields get updated
  #       - verify remove subscriber

end
