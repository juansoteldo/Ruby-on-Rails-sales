require 'test_helper'

class CampaignMonitorJobTest < ActiveJob::TestCase

  # TODO: - create a temporary list for test environment
  #       - do testing
  #       - always remember to delete the list after running the test suite

  setup do
    # client_id = Rails.application.credentials[:cm][:client_id]
    # HTTParty https://api.createsend.com/api/v3.3/lists/f8075ee31787c96b3a18500d84b8236a.json
  end

  teardown do

  end

  def parse_response(response)
    JSON.parse(response, symbolize_names: true)
  end

  # test 'add or update user to all list' do
  #   user = users(:wpcf7)
  #   CampaignMonitorActionJob.perform_now(user: user, method: 'add_or_update_user_to_all_list')
  #   response = CampaignMonitorActionJob.perform_now(user: user, method: 'get_subscriber_details_in_all')
  #   assert response.code == 200
  # end

  # test 'add user to marketing list' do
  #   user = users(:wpcf7)
  #   CampaignMonitorActionJob.perform_now(user: user, method: 'add_user_to_marketing_list')
  #   response = CampaignMonitorActionJob.perform_now(user: user, method: 'get_subscriber_details_in_marketing')
  #   assert response.code == 200
  # end

  # test 'delete user from list' do
  #   user = users(:wpcf7)
  #   CampaignMonitorActionJob.perform_now(user: user, method: 'delete_subscriber')
  #   response = CampaignMonitorActionJob.perform_now(user: user, method: 'get_subscriber_details_in_all')
  #   assert response.code == 200
  #   data = parse_response(response)
  #   assert data[:State] == 'Deleted'
  # end

  test 'create a list' do
    list_title = "temp_list_#{Time.now.to_i}"

    response = CampaignMonitorActionJob.perform_now(method: 'create_list', list_title: list_title)
    list_id = parse_response(response)
    assert !list_id.nil?

    response = CampaignMonitorActionJob.perform_now(method: 'delete_list', list_id: list_id)
    assert response.code == 200
  end

  # def new_webhook(new_params)
  #   Webhook.create! source: "WordPress", action_name: "requests_create", params: wpcf7_params.dup.merge(new_params)
  # end

  # test "opts user back in" do
  #   user = users(:wpcf7)
  #   user.update! presales_opt_in: false, marketing_opt_in: false, crm_opt_in: false
  #   CreateRequestJob.perform_now webhook: new_webhook({})

  #   assert user.reload.presales_opt_in
  #   assert user.crm_opt_in
  #   assert user.marketing_opt_in
  # end

  # test "should add a new request with an image" do
  #   art_samples = {
  #     art_sample_1: @image_data
  #   }
  #   content_type = content_type(@image_file)
  #   request = CreateRequestJob.perform_now webhook: new_webhook(art_samples)
  #   assert request
  #   assert request.images.any?
  #   assert request.images.decorate.all?(&:exists?)
  #   assert content_type.include?(request.images.first.decorate.content_type)
  # end

  # test "should add a new request with 2 images" do
  #   art_samples = {
  #     art_sample_1: @image_data,
  #     art_sample_2: @image_data2
  #   }
  #   request = CreateRequestJob.perform_now webhook: new_webhook(art_samples)
  #   assert request
  #   assert_equal request.images.count, 2
  # end

  # test "should clear art_sample fields" do
  #   art_samples = {
  #     art_sample_1: @image_data,
  #     art_sample_2: @image_data2
  #   }
  #   webhook = new_webhook(art_samples)
  #   CreateRequestJob.perform_now webhook: webhook
  #   assert_nil webhook.reload.params[:art_sample_1]
  #   assert_nil webhook.params[:art_sample_2]
  # end
end
