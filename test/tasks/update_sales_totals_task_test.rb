# test/tasks/rake_task_file_test.rb

require 'test_helper'
require 'rake'

class UpdateSalesTotalsTaskTest < ActiveSupport::TestCase
  def setup
    CtdWorklist::Application.load_tasks
  end

  test "updating sales totals" do
    Rake::Task["recurring:update_sales_totals"].invoke
  end
end