# test/tasks/update_sales_totals_task_test.rb

require 'test_helper'
require 'rake'

class UpdateSalesTotalsTaskTest < ActiveSupport::TestCase
  def setup
    CtdSales::Application.load_tasks
  end

  test "updating sales totals" do
    skip("Skipped because it takes much too long")
    Rake::Task["recurring:update_sales_totals"].invoke
  end
end