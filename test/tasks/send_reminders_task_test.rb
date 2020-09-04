# test/tasks/update_sales_totals_task_test.rb

require "test_helper"
require "rake"

class SendRemindersTaskTest < ActiveSupport::TestCase
  def setup
    CtdSales::Application.load_tasks
  end

  test "sending reminders" do
    Rake::Task["recurring:send_reminders"].invoke
  end
end
