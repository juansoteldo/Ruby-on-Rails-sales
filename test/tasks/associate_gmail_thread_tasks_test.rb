# test/tasks/update_sales_totals_task_test.rb

require 'test_helper'
require 'rake'

class AssociateGmailThreadsTaskTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    @user = users(:one)
    RequestMailer.delivery_method = :smtp
    Settings.streak.create_boxes = true
    CtdWorklist::Application.load_tasks
    @image_file = file_fixture_copy("test.jpg")
    @image_url = "https://www.ece.rice.edu/~wakin/images/lena512.bmp"
  end

  teardown do
    RequestMailer.delivery_method = :test
    Settings.streak.create_boxes = false
  end

  test "associate gmail threads" do
    request = Request.create! user: @user, description: "TEST, DO NOT REPLY"
    request.update! art_sample_1: @image_url

    perform_enqueued_jobs do
      perform_enqueued_jobs do # deliver_emails
        perform_enqueued_jobs do # streak_box_create
          request.ensure_streak_box
        end
      end
    end
    message = wait_for_and_get_message(request.reload.streak_box_key)
    assert_not_nil message
    Rake::Task["recurring:associate_gmail_threads"].invoke
    assert_equal request.reload.thread_gmail_id, message.thread_id
    box = MostlyStreak::Box.find(message.streak_box_key)
    assert_equal box.notes, message.text_body
  end

  def wait_for_and_get_message(streak_box_key)
    message = nil
    start_time = Time.now
    until message
      sleep 5
      messages = new_start_design_messages_for_streak_box(streak_box_key)
      message = messages&.any? && messages.first || nil
      break if start_time + 30.seconds < Time.now
    end
    message
  end
end