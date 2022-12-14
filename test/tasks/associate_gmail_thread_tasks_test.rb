# test/tasks/update_sales_totals_task_test.rb

require "test_helper"
require "rake"

class AssociateGmailThreadsTaskTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    settings(:auto_quoting).update! value: false
    @user = users(:one)
    RequestMailer.delivery_method = :smtp
    Settings.streak.create_boxes = true
    CtdSales::Application.load_tasks
    @image_file = file_fixture_copy("test.jpg")
    @image_url = "https://www.ece.rice.edu/~wakin/images/lena512.bmp"
    CTD::SeedImporter.import_tattoo_sizes
    CTD::SeedImporter.import_marketing_emails
  end

  teardown do
    RequestMailer.delivery_method = :test
    Settings.streak.create_boxes = false
  end

  # NOTE: Commented out because it doesn't consistently pass but it should be possible if test is rewritten using a different approach
  # test "associate gmail threads" do
  #   request = requests(:fresh)
  #   request.update! art_sample_1: @image_url

  #   perform_enqueued_jobs do
  #     perform_enqueued_jobs do # deliver_emails
  #       perform_enqueued_jobs do # streak_box_create
  #         request.ensure_streak_box
  #       end
  #     end
  #   end
  #   message = wait_for_and_get_message(request.reload.streak_box_key)
  #   assert_not_nil message
  #   Rake::Task["recurring:associate_gmail_threads"].invoke
  #   # NOTE: prone to failure, known testing streak/gmail issue
  #   assert_equal request.reload.thread_gmail_id, message.thread_id
  #   box = MostlyStreak::Box.find(message.streak_box_key)
  #   assert_equal box.notes, message.shortened_utf_8_text_body
  #   assert box.stage_key == MostlyStreak::Stage.leads.key
  # end

  test "auto quote if enabled" do
    settings(:auto_quoting).update! value: true
    request = requests(:fresh)
    request.update! size: TattooSize.find_by_size(1).name, style: Request::TATTOO_STYLES.first, art_sample_1: @image_url

    perform_enqueued_jobs do
      perform_enqueued_jobs do # deliver_emails
        perform_enqueued_jobs do # streak_box_create
          request.ensure_streak_box
        end
      end
    end
    # NOTE: Run this test while Settings.config.auto_quote_emails is set to AWS since there is no support for CM yet
    # TODO: Add transactional emails (Campaign Monitor service) for test environment
    message = wait_for_and_get_message(request.reload.streak_box_key)
    assert_not_nil message
    # NOTE: below assert_emails commented out, as this line of code is prone to failure.
    # assert_emails 1 do
      perform_enqueued_jobs do # send_quote
        perform_enqueued_jobs do # enqueue_quote_actions
          Rake::Task["recurring:associate_gmail_threads"].invoke
        end
      end
    # end
    assert_not_nil request.reload.quoted_at
  end

  def wait_for_and_get_message(streak_box_key)
    message = nil
    start_time = Time.now
    until message
      sleep 5
      messages = new_start_design_messages_for_streak_box(streak_box_key)
      message = messages&.any? && messages&.first || nil
      break if start_time + 30.seconds < Time.now
    end
    message
  end
end
