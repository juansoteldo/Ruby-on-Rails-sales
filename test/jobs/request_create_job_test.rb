require 'test_helper'

class RequestCreateJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    change_delivery_method_to :test
    @image_file = file_fixture_copy("test.jpg")
    @image_file2 = file_fixture_copy("test2.png")
    RequestImage.joins(:user).where(users: { email: wpcf7_params[:email] }).each &:destroy!
    Request.joins(:user).where(users: { email: wpcf7_params[:email] }).each &:destroy!
    User.where(email: wpcf7_params[:email]).delete_all
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test "should add a new request with an image" do
    art_samples = {
        art_sample_1: @image_file
    }
    content_type = content_type(@image_file)
    RequestCreateJob.perform_now(wpcf7_params.dup.merge(art_samples))
    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert request
    assert request.images.any?
    assert request.images.decorate.all? &:exists?
    assert content_type.include?(request.images.first.decorate.content_type)
  end

  test "should add a new request with 2 images" do
    art_samples = {
        art_sample_1: @image_file,
        art_sample_2: @image_file2
    }
    RequestCreateJob.perform_now(wpcf7_params.dup.merge(art_samples))
    request = Request.joins(:user).where(users: { email: wpcf7_params[:email] }).first
    assert request
    assert request.images.count == 2
  end

  test "should cleanup both source image files" do
    art_samples = {
        art_sample_1: @image_file,
        art_sample_2: @image_file2
    }
    RequestCreateJob.perform_now(wpcf7_params.dup.merge(art_samples))
    assert_not File.exist?(@image_file)
    assert_not File.exist?(@image_file2)
  end

  test "should send opt_in and start_design emails" do
    art_samples = {
      art_sample_1: @image_file,
      art_sample_2: @image_file2
    }
    Request.skip_creating_streak_boxes = false
    assert_enqueued_emails 2 do
      RequestCreateJob.perform_now(wpcf7_params.dup.merge(art_samples))
    end
  end
end
