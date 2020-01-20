require 'test_helper'

class RequestCreateJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    RequestMailer.delivery_method = :test
    @image_file = file_fixture_copy("test.jpg")
    @image_file2 = file_fixture_copy("test2.png")
    @image_data = "data:image/jpg;base64," + Base64.encode64(@image_file.read.to_s)
    @image_data2 = "data:image/png;base64," + Base64.encode64(@image_file2.read.to_s)
    RequestImage.joins(:user).where(users: { email: wpcf7_params[:email] }).each &:destroy!
    Request.joins(:user).where(users: { email: wpcf7_params[:email] }).each &:destroy!
    User.where(email: wpcf7_params[:email]).delete_all
  end

  teardown do
    @image_file.unlink if @image_file.exist?
    @image_file2.unlink if @image_file2.exist?
  end

  def new_webhook(new_params)
    Webhook.create! source: "WordPress", action_name: "requests_create", params: wpcf7_params.dup.merge(new_params)
  end

  test "should add a new request with an image" do
    art_samples = {
      art_sample_1: @image_data,
    }
    content_type = content_type(@image_file)
    RequestCreateJob.perform_now webhook: new_webhook(art_samples)
    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert request
    assert request.images.any?
    assert request.images.decorate.all? &:exists?
    assert content_type.include?(request.images.first.decorate.content_type)
  end

  test "should add a new request with 2 images" do
    art_samples = {
      art_sample_1: @image_data,
      art_sample_2: @image_data2,
    }
    RequestCreateJob.perform_now webhook: new_webhook(art_samples)
    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert request
    assert request.images.count == 2
  end

  test "should clear art_sample fields" do
    art_samples = {
      art_sample_1: @image_data,
      art_sample_2: @image_data2,
    }
    webhook = new_webhook(art_samples)
    RequestCreateJob.perform_now webhook: webhook
    assert_nil webhook.reload.params[:art_sample_1]
    assert_nil webhook.params[:art_sample_2]
  end
end
