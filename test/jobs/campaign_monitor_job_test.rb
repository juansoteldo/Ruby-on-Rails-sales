require 'test_helper'
# require 'string_utils'

class CampaignMonitorJobTest < ActiveJob::TestCase

  attr_accessor :user
  attr_accessor :list_id

  def parse_response(response)
    JSON.parse(response, symbolize_names: true)
  end

  setup do
    @user = users(:test)
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

end
