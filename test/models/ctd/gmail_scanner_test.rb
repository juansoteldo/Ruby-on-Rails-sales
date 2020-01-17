require 'test_helper'

class CTD::GmailScannerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    RequestMailer.delivery_method = :smtp
    Request.skip_creating_streak_boxes = false
  end

  teardown do
    RequestMailer.delivery_method = :test
    Request.skip_creating_streak_boxes = true
  end

  test "make_design_requests_boxes" do
    request = Request.create! user: @user
    message = wait_for_and_get_message(request.streak_box_key)
    assert_not_nil message
    CTD::GmailScanner.make_design_requests_boxes

    assert_equal request.reload.thread_gmail_id, message.thread_id
  end

  def wait_for_and_get_message(streak_box_key)
    message = nil
    start_time = Time.now
    until message
      sleep 5
      messages = start_design_messages_for_streak_box(streak_box_key)
      message = messages&.any? && messages.first || nil
      break if start_time + 10.seconds < Time.now
    end
    message
  end
end
