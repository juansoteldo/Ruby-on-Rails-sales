require 'test_helper'

class StreakBoxCreateJobTest < ActiveJob::TestCase
  setup do
    @request = requests(:fresh)
  end

  test "should create a box with the correct attributes" do
    StreakBoxCreateJob.perform_now(@request)
    assert_not_nil @request.streak_box_key
    box = MostlyStreak::Box.find(@request.streak_box_key)
    assert_equal @request.description, box.notes
  end
end