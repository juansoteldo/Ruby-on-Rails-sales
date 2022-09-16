# test/tasks/update_sales_totals_task_test.rb

require "test_helper"
require "rake"

class CampaignMonitorTaskTest < ActiveSupport::TestCase
  def setup
    CtdSales::Application.load_tasks
  end

  test "export_fresh_users" do
    Rake::Task["cm:export_fresh_users"].invoke
  end
end
