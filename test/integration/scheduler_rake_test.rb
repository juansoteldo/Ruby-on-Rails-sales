# test/tasks/rake_task_file_test.rb

require 'test_helper'
require 'rake'

class SchedulerRakeTest < ActiveSupport::TestCase
  def setup
    ApplicationName::Application.load_tasks
  end

  test "updating sales totals" do
    Rake::Task["scheduler:update_sales_totals"].invoke
  end
end